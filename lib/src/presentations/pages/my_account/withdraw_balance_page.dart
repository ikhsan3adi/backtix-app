import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/user/withdraw/withdraw_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_from_enum.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_method_enum.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_request_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

class WithdrawBalancePage extends StatelessWidget {
  const WithdrawBalancePage({
    super.key,
    this.withdrawFrom,
  });

  final WithdrawFrom? withdrawFrom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Withdraw'),
      ),
      body: ResponsivePadding(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: BlocProvider(
                create: (_) => GetIt.I<WithdrawCubit>()..init(),
                child: _WithdrawForm(withdrawFrom: withdrawFrom),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawForm extends StatefulWidget {
  const _WithdrawForm({this.withdrawFrom});

  final WithdrawFrom? withdrawFrom;

  @override
  State<_WithdrawForm> createState() => _WithdrawFormState();
}

class _WithdrawFormState extends State<_WithdrawForm> {
  static const double _minWithdraw = 50000;

  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer();

  final _nominalController = TextEditingController();
  final _fromController = TextEditingController();

  late final ValueNotifier<WithdrawFrom> _withdrawFrom;
  final _withdrawMethod = ValueNotifier<WithdrawMethod>(
    WithdrawMethod.transfer,
  );
  final _otherWithrawMethodController = TextEditingController();

  final _detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _withdrawFrom = ValueNotifier(widget.withdrawFrom ?? WithdrawFrom.balance);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _nominalController.dispose();
    _fromController.dispose();
    _withdrawFrom.dispose();
    _withdrawMethod.dispose();
    _otherWithrawMethodController.dispose();
    _detailController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverList.list(
        children: [
          BlocConsumer<WithdrawCubit, WithdrawState>(
            listener: (context, state) => state.whenOrNull(
              initial: () => SimpleLoadingDialog.hide(context),
              loading: () => SimpleLoadingDialog.show(context),
              success: (_) async {
                SimpleLoadingDialog.hide(context);
                context
                    .read<AuthBloc>()
                    .add(const AuthEvent.updateUserDetails());
                await SuccessBottomSheet.show(context);
                if (context.mounted) context.pop(true);
                return;
              },
              failed: (exception) async {
                SimpleLoadingDialog.hide(context);
                return ErrorDialog.show(context, exception);
              },
            ),
            builder: (context, state) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _nominalInputField(state)),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Admin fee',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      Text(
                        state.maybeWhen(
                          loaded: (_, fee) => '+${Utils.toCurrency(fee)}',
                          orElse: () => 'loading...',
                        ),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InputChip(
                  label: Text(Utils.toCurrency(100000)),
                  onPressed: () => _setNominal('100.000'),
                ),
                const SizedBox(width: 6),
                InputChip(
                  label: Text(Utils.toCurrency(200000)),
                  onPressed: () => _setNominal('200.000'),
                ),
                const SizedBox(width: 6),
                InputChip(
                  label: Text(Utils.toCurrency(500000)),
                  onPressed: () => _setNominal('500.000'),
                ),
                const SizedBox(width: 6),
                InputChip(
                  label: Text(Utils.toCurrency(1000000)),
                  onPressed: () => _setNominal('1.000.000'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownMenu<WithdrawFrom>(
                  initialSelection: widget.withdrawFrom ?? WithdrawFrom.balance,
                  controller: _fromController,
                  requestFocusOnTap: true,
                  label: const Text('From'),
                  width: 180,
                  inputDecorationTheme: _dropdownDecoration(context),
                  onSelected: (WithdrawFrom? v) {
                    if (v == null) return;
                    _withdrawFrom.value = v;
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: WithdrawFrom.balance,
                      label: 'BALANCE',
                      trailingIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    DropdownMenuEntry(
                      value: WithdrawFrom.revenue,
                      label: 'REVENUE',
                      trailingIcon: Icon(Icons.show_chart_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<WithdrawCubit, WithdrawState>(
                builder: (context, state) {
                  return ValueListenableBuilder(
                    valueListenable: _withdrawFrom,
                    builder: (context, from, _) {
                      return Expanded(
                        child: Text(
                          state.maybeWhen(
                            orElse: () => 'Loading...',
                            loaded: (balance, _) {
                              return Utils.toCurrency(
                                switch (from) {
                                  WithdrawFrom.balance => balance.balance,
                                  WithdrawFrom.revenue => balance.revenue,
                                },
                                decimalDigits: 2,
                              );
                            },
                          ),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownMenu<WithdrawMethod>(
                  initialSelection: WithdrawMethod.transfer,
                  requestFocusOnTap: true,
                  label: const Text('Withdraw method'),
                  helperText: ' ',
                  width: 180,
                  inputDecorationTheme: _dropdownDecoration(context),
                  onSelected: (WithdrawMethod? v) {
                    if (v == null) return;
                    _withdrawMethod.value = v;
                  },
                  dropdownMenuEntries: [
                    ...WithdrawMethod.values.map(
                      (e) => DropdownMenuEntry(
                        value: e,
                        label: e.value,
                        trailingIcon: e == WithdrawMethod.transfer
                            ? const Icon(Icons.account_balance_outlined)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _withdrawMethod,
                  builder: (context, method, _) {
                    if (method != WithdrawMethod.other) return const SizedBox();

                    return CustomTextFormField(
                      controller: _otherWithrawMethodController,
                      validator: Validatorless.multiple([
                        if (method == WithdrawMethod.other)
                          Validatorless.required('Required'),
                        Validatorless.max(24, 'Max 24 characters'),
                      ]),
                      maxLines: 1,
                      maxLength: 24,
                      debounce: true,
                      debouncer: _debouncer,
                      decoration: const InputDecoration(labelText: 'Method'),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: _detailController,
            validator: Validatorless.multiple([
              Validatorless.required('Required'),
            ]),
            minLines: 2,
            maxLength: 1024,
            debounce: true,
            debouncer: _debouncer,
            decoration: const InputDecoration(
              labelText: 'Detail',
              hintText: 'Number',
              alignLabelWithHint: true,
            ),
          ),
          _submitButton,
        ],
      ),
    );
  }

  void _setNominal(String value) {
    _nominalController.value = _nominalController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Widget _nominalInputField(WithdrawState state) {
    final fee = state.mapOrNull(loaded: (s) => s.adminFee) ?? 0;
    final double minWithdrawWithFee = _minWithdraw + fee;
    return ValueListenableBuilder(
      valueListenable: _nominalController,
      builder: (context, nominal, _) {
        return ValueListenableBuilder(
          valueListenable: _withdrawFrom,
          builder: (context, from, _) {
            return CustomTextFormField(
              controller: _nominalController,
              debounce: true,
              debouncer: _debouncer,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [CurrencyInputFormatter()],
              validator: (v) => Validatorless.numbersBetweenInterval(
                _minWithdraw,
                state.maybeWhen(
                  orElse: () => double.infinity,
                  loaded: (b, fee) => switch (from) {
                    WithdrawFrom.balance => b.balance - fee,
                    WithdrawFrom.revenue => b.revenue - fee,
                  }
                      .toDouble(),
                ),
                state.maybeWhen(
                  orElse: () => 'Minimum $_minWithdraw',
                  loaded: (b, fee) {
                    const insuffMsg = 'Insufficient balance!';
                    switch (from) {
                      case WithdrawFrom.balance:
                        if (b.balance < minWithdrawWithFee) return insuffMsg;
                        break;
                      case WithdrawFrom.revenue:
                        if (b.revenue < minWithdrawWithFee) return insuffMsg;
                        break;
                    }
                    return switch (from) {
                      WithdrawFrom.balance =>
                        'Minimum $_minWithdraw, Max ${b.balance - fee}',
                      WithdrawFrom.revenue =>
                        'Minimum $_minWithdraw, Max ${b.revenue - fee}',
                    };
                  },
                ),
              ).call(Utils.unformatCurrency(v ?? '0').floor().toString()),
              decoration: InputDecoration(
                labelText: 'Nominal',
                hintText: '0',
                prefixText: Constant.currencyPrefix,
                helperText:
                    'Balance deduction: ${Utils.unformatCurrency(nominal.text) + fee}',
              ),
            );
          },
        );
      },
    );
  }

  Widget get _submitButton {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<WithdrawCubit, WithdrawState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: state.maybeWhen(
              loading: () => null,
              success: (_) => null,
              orElse: () => () => _submit(context),
            ),
            child: Text(
              state.maybeMap(
                loading: (_) => 'Processing...',
                success: (_) => 'Success',
                orElse: () => 'Withdraw',
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool useOtherMethod = _withdrawMethod.value == WithdrawMethod.other;

    final withdrawRequest = WithdrawRequestModel(
      amount: Utils.unformatCurrency(_nominalController.value.text),
      from: _withdrawFrom.value,
      method: useOtherMethod
          ? _otherWithrawMethodController.value.text
          : _withdrawMethod.value.value,
      details: _detailController.value.text,
    );

    context.read<WithdrawCubit>().requestWithdrawal(withdrawRequest);
  }

  InputDecorationTheme _dropdownDecoration(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        width: 2,
        color: context.colorScheme.onSurface,
      ),
    );

    return InputDecorationTheme(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(
          width: 2.2,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}
