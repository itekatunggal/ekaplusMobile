class InvoiceDetailItem {
  final String itemCode;
  final String itemName;
  final String description;
  final String itemGroup;
  final double qty;
  final String uom;
  final double rate;
  final double amount;
  final String warehouse;
  final String salesOrder;
  final String deliveryNote;

  const InvoiceDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.itemGroup,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
    required this.warehouse,
    required this.salesOrder,
    required this.deliveryNote,
  });

  factory InvoiceDetailItem.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailItem(
      itemCode:     json['item_code'] ?? '-',
      itemName:     json['item_name'] ?? '-',
      description:  json['description'] ?? '-',
      itemGroup:    json['item_group'] ?? '-',
      qty:          (json['qty'] as num?)?.toDouble() ?? 0.0,
      uom:          json['uom'] ?? '-',
      rate:         (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount:       (json['amount'] as num?)?.toDouble() ?? 0.0,
      warehouse:    json['warehouse'] ?? '-',
      salesOrder:   json['sales_order'] ?? '',
      deliveryNote: json['delivery_note'] ?? '',
    );
  }
}

class InvoiceDetailTax {
  final String type;
  final String accountHead;
  final double rate;
  final double amount;

  const InvoiceDetailTax({
    required this.type,
    required this.accountHead,
    required this.rate,
    required this.amount,
  });

  factory InvoiceDetailTax.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailTax(
      type:        json['charge_type'] ?? '-',
      accountHead: json['account_head'] ?? '-',
      rate:        (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount:      (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceDetailPaymentSchedule {
  final String paymentTerm;
  final String dueDate;
  final double paymentAmount;
  final double outstanding;
  final double paidAmount;

  const InvoiceDetailPaymentSchedule({
    required this.paymentTerm,
    required this.dueDate,
    required this.paymentAmount,
    required this.outstanding,
    required this.paidAmount,
  });

  factory InvoiceDetailPaymentSchedule.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailPaymentSchedule(
      paymentTerm:   json['payment_term'] ?? '-',
      dueDate:       json['due_date'] ?? '-',
      paymentAmount: (json['payment_amount'] as num?)?.toDouble() ?? 0.0,
      outstanding:   (json['outstanding'] as num?)?.toDouble() ?? 0.0,
      paidAmount:    (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceDetail {
  // ── Info utama ─────────────────────────────────────────────────────────────
  final String name;
  final String postingDate;
  final String dueDate;
  final String customer;
  final String customerName;
  final String status;
  final String company;
  final double grandTotal;
  final double outstandingAmount;
  final double totalTaxes;

  // ── Address ────────────────────────────────────────────────────────────────
  final String customerAddress;
  final String addressDisplay;
  final String shippingAddressName;

  // ── Customer PO ────────────────────────────────────────────────────────────
  final String poNo;

  // ── Discount ───────────────────────────────────────────────────────────────
  final String applyDiscountOn;
  final double additionalDiscountPercentage;
  final double discountAmount;
  final double baseDiscountAmount;

  // ── Bank ───────────────────────────────────────────────────────────────────
  final String bank;
  final String namaRekening;
  final String nomorRekening;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<InvoiceDetailItem> items;
  final List<InvoiceDetailTax> taxes;
  final List<InvoiceDetailPaymentSchedule> paymentSchedule;

  const InvoiceDetail({
    required this.name,
    required this.postingDate,
    required this.dueDate,
    required this.customer,
    required this.customerName,
    required this.status,
    required this.company,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.totalTaxes,
    required this.customerAddress,
    required this.addressDisplay,
    required this.shippingAddressName,
    required this.poNo,
    required this.applyDiscountOn,
    required this.additionalDiscountPercentage,
    required this.discountAmount,
    required this.baseDiscountAmount,
    required this.bank,
    required this.namaRekening,
    required this.nomorRekening,
    required this.items,
    required this.taxes,
    required this.paymentSchedule,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    final rawItems    = json['items'] as List? ?? [];
    final rawTaxes    = json['taxes'] as List? ?? [];
    final rawPayments = json['payment_schedule'] as List? ?? [];

    return InvoiceDetail(
      name:                         json['name'] ?? '-',
      postingDate:                  json['posting_date'] ?? '-',
      dueDate:                      json['due_date'] ?? '-',
      customer:                     json['customer'] ?? '-',
      customerName:                 json['customer_name'] ?? '-',
      status:                       json['status'] ?? '-',
      company:                      json['company'] ?? '-',
      grandTotal:                   (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      outstandingAmount:            (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      totalTaxes:                   (json['total_taxes_and_charges'] as num?)?.toDouble() ?? 0.0,
      customerAddress:              json['customer_address'] ?? '-',
      addressDisplay:               json['address_display'] ?? '-',
      shippingAddressName:          json['shipping_address_name'] ?? '-',
      poNo:                         json['po_no'] ?? '-',
      applyDiscountOn:              json['apply_discount_on'] ?? '-',
      additionalDiscountPercentage: (json['additional_discount_percentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount:               (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      baseDiscountAmount:           (json['base_discount_amount'] as num?)?.toDouble() ?? 0.0,
      bank:                         json['bank'] ?? '-',
      namaRekening:                 json['nama_rekening'] ?? '-',
      nomorRekening:                json['nomor_rekening'] ?? '-',
      items:           rawItems.map((e) => InvoiceDetailItem.fromJson(e as Map<String, dynamic>)).toList(),
      taxes:           rawTaxes.map((e) => InvoiceDetailTax.fromJson(e as Map<String, dynamic>)).toList(),
      paymentSchedule: rawPayments.map((e) => InvoiceDetailPaymentSchedule.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Convert ke Map untuk dikirim ke InvoiceDetailPage
  Map<String, dynamic> toDetailMap() {
    // ── delivery — ambil unik dari items ───────────────────────────────────
    final deliveryNames = <String>{};
    final mappedDelivery = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item.deliveryNote.isNotEmpty && deliveryNames.add(item.deliveryNote)) {
        mappedDelivery.add({
          'name':     item.deliveryNote,
          'customer': customer,
          'date':     postingDate,
          'status':   status,
        });
      }
    }

    // ── sales order — ambil unik dari items ────────────────────────────────
    final salesNames = <String>{};
    final mappedSales = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item.salesOrder.isNotEmpty && salesNames.add(item.salesOrder)) {
        mappedSales.add({
          'name':     item.salesOrder,
          'customer': customer,
          'date':     postingDate,
          'status':   status,
        });
      }
    }

    return {
      // ── Header ────────────────────────────────────────────────────────────
      'series':   name,
      'date':     postingDate,
      'customer': customer,
      'dueDate':  dueDate,
      'status':   status,
      'nilai':    grandTotal.toInt(),
      'terbayar': (grandTotal - outstandingAmount).toInt(),
      'taxTotal': totalTaxes.toInt(),

      // ── Address ───────────────────────────────────────────────────────────
      'address': {
        'customerAddress':     customerAddress,
        'addressDisplay':      addressDisplay,
        'shippingAddressName': shippingAddressName,
        'contactPerson':       '-',
      },

      // ── Customer PO ───────────────────────────────────────────────────────
      'customerPO': {
        'number': poNo,
        'date':   '-',
      },

      // ── Discount ──────────────────────────────────────────────────────────
      'discount': {
        'applyOn':         applyDiscountOn,
        'discountPercent': additionalDiscountPercentage,
        'discountAmount':  discountAmount.toInt(),
      },

      // ── Items ─────────────────────────────────────────────────────────────
      'items': items.map((item) => {
        'itemCode': item.itemCode,
        'itemName': item.itemName,
        'qty':      item.qty,
        'uom':      item.uom,
        'date':     postingDate,
        'rate':     item.rate.toInt(),
        'amount':   item.amount.toInt(),
      }).toList(),

      // ── Taxes ─────────────────────────────────────────────────────────────
      'taxes': taxes.map((t) => {
        'type':        t.type,
        'accountHead': t.accountHead,
        'rate':        t.rate,
        'amount':      t.amount.toInt(),
      }).toList(),

      // ── Payments — dari payment_schedule ──────────────────────────────────
      'payments': paymentSchedule.map((p) => {
        'name':              p.paymentTerm,
        'paymentType':       'Receive',
        'postingDate':       postingDate,
        'customer':          customer,
        'paidAmount':        p.paidAmount.toInt(),
        'dueDate':           p.dueDate,
        'grandTotal':        grandTotal.toInt(),
        'outstandingAmount': p.outstanding.toInt(),
        'allocatedAmount':   p.paidAmount.toInt(),
      }).toList(),

      // ── Delivery & Sales Order — dari items ───────────────────────────────
      'delivery': mappedDelivery,
      'sales':    mappedSales,
    };
  }
}