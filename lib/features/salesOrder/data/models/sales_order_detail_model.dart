class SalesOrderDetailItem {
  final String itemCode;
  final String itemName;
  final String description;
  final String itemGroup;
  final String subKategori;
  final String kategoriBarang;
  final double qty;
  final double deliveredQty;
  final String uom;
  final String deliveryDate;
  final double rate;
  final double amount;
  final String warehouse;

  const SalesOrderDetailItem({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.itemGroup,
    required this.subKategori,
    required this.kategoriBarang,
    required this.qty,
    required this.deliveredQty,
    required this.uom,
    required this.deliveryDate,
    required this.rate,
    required this.amount,
    required this.warehouse,
  });

  factory SalesOrderDetailItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailItem(
      itemCode:      json['item_code'] ?? '-',
      itemName:      json['item_name'] ?? '-',
      description:   json['description'] ?? '-',
      itemGroup:     json['item_group'] ?? '-',
      subKategori:   json['sub_kategori'] ?? '-',
      kategoriBarang:json['kategori_barang'] ?? '-',
      qty:           (json['qty'] as num?)?.toDouble() ?? 0.0,
      deliveredQty:  (json['delivered_qty'] as num?)?.toDouble() ?? 0.0,
      uom:           json['uom'] ?? '-',
      deliveryDate:  json['delivery_date'] ?? '-',
      rate:          (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount:        (json['amount'] as num?)?.toDouble() ?? 0.0,
      warehouse:     json['warehouse'] ?? '-',
    );
  }
}

class SalesOrderDetailTax {
  final String type;
  final String accountHead;
  final double rate;
  final double amount;

  const SalesOrderDetailTax({
    required this.type,
    required this.accountHead,
    required this.rate,
    required this.amount,
  });

  factory SalesOrderDetailTax.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailTax(
      type:        json['charge_type'] ?? '-',
      accountHead: json['account_head'] ?? '-',
      rate:        (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount:      (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesOrderDetailPaymentSchedule {
  final String paymentTerm;
  final String dueDate;
  final double paymentAmount;
  final double outstanding;
  final double paidAmount;

  const SalesOrderDetailPaymentSchedule({
    required this.paymentTerm,
    required this.dueDate,
    required this.paymentAmount,
    required this.outstanding,
    required this.paidAmount,
  });

  factory SalesOrderDetailPaymentSchedule.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailPaymentSchedule(
      paymentTerm:   json['payment_term'] ?? '-',
      dueDate:       json['due_date'] ?? '-',
      paymentAmount: (json['payment_amount'] as num?)?.toDouble() ?? 0.0,
      outstanding:   (json['outstanding'] as num?)?.toDouble() ?? 0.0,
      paidAmount:    (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesOrderDetail {
  // ── Info utama ─────────────────────────────────────────────────────────────
  final String name;
  final String transactionDate;
  final String deliveryDate;
  final String customer;
  final String customerName;
  final String status;
  final String deliveryStatus;
  final String billingStatus;
  final String company;
  final double grandTotal;
  final double advancePaid;
  final double totalTaxes;

  // ── Info tambahan ──────────────────────────────────────────────────────────
  final String sales;
  final String catatan;
  final String opsiPengiriman;
  final String lokasi;
  final String paymentTermsTemplate;
  final String koordinator;

  // ── Address ────────────────────────────────────────────────────────────────
  final String customerAddress;
  final String addressDisplay;
  final String shippingAddressName;

  // ── Discount ───────────────────────────────────────────────────────────────
  final String applyDiscountOn;
  final double additionalDiscountPercentage;
  final double discountAmount;
  final double baseDiscountAmount;

  // ── Lists ──────────────────────────────────────────────────────────────────
  final List<SalesOrderDetailItem> items;
  final List<SalesOrderDetailTax> taxes;
  final List<SalesOrderDetailPaymentSchedule> paymentSchedule;

  const SalesOrderDetail({
    required this.name,
    required this.transactionDate,
    required this.deliveryDate,
    required this.customer,
    required this.customerName,
    required this.status,
    required this.deliveryStatus,
    required this.billingStatus,
    required this.company,
    required this.grandTotal,
    required this.advancePaid,
    required this.totalTaxes,
    required this.sales,
    required this.catatan,
    required this.opsiPengiriman,
    required this.lokasi,
    required this.paymentTermsTemplate,
    required this.koordinator,
    required this.customerAddress,
    required this.addressDisplay,
    required this.shippingAddressName,
    required this.applyDiscountOn,
    required this.additionalDiscountPercentage,
    required this.discountAmount,
    required this.baseDiscountAmount,
    required this.items,
    required this.taxes,
    required this.paymentSchedule,
  });

  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems    = json['items'] as List? ?? [];
    final rawTaxes    = json['taxes'] as List? ?? [];
    final rawPayments = json['payment_schedule'] as List? ?? [];

    return SalesOrderDetail(
      name:                         json['name'] ?? '-',
      transactionDate:              json['transaction_date'] ?? '-',
      deliveryDate:                 json['delivery_date'] ?? '-',
      customer:                     json['customer'] ?? '-',
      customerName:                 json['customer_name'] ?? '-',
      status:                       json['status'] ?? '-',
      deliveryStatus:               json['delivery_status'] ?? '-',
      billingStatus:                json['billing_status'] ?? '-',
      company:                      json['company'] ?? '-',
      grandTotal:                   (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      advancePaid:                  (json['advance_paid'] as num?)?.toDouble() ?? 0.0,
      totalTaxes:                   (json['total_taxes_and_charges'] as num?)?.toDouble() ?? 0.0,
      sales:                        json['sales'] ?? '-',
      catatan:                      json['catatan'] ?? '-',
      opsiPengiriman:               json['opsi_pengiriman'] ?? '-',
      lokasi:                       json['lokasi'] ?? '-',
      paymentTermsTemplate:         json['payment_terms_template'] ?? '-',
      koordinator:                  json['koordinator'] ?? '-',
      customerAddress:              json['customer_address'] ?? '-',
      addressDisplay:               json['address_display'] ?? '-',
      shippingAddressName:          json['shipping_address_name'] ?? '-',
      applyDiscountOn:              json['apply_discount_on'] ?? '-',
      additionalDiscountPercentage: (json['additional_discount_percentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount:               (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      baseDiscountAmount:           (json['base_discount_amount'] as num?)?.toDouble() ?? 0.0,
      items:           rawItems.map((e) => SalesOrderDetailItem.fromJson(e as Map<String, dynamic>)).toList(),
      taxes:           rawTaxes.map((e) => SalesOrderDetailTax.fromJson(e as Map<String, dynamic>)).toList(),
      paymentSchedule: rawPayments.map((e) => SalesOrderDetailPaymentSchedule.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Convert ke Map untuk dikirim ke SalesOrderDetailPage
  Map<String, dynamic> toDetailMap() {
    return {
      // ── Header ────────────────────────────────────────────────────────────
      'series':          name,
      'date':            transactionDate,
      'customer':        customer,
      'customerName':    customerName,
      'dueDate':         deliveryDate,
      'status':          status,
      'deliveryStatus':  deliveryStatus,
      'billingStatus':   billingStatus,
      'nilai':           grandTotal.toInt(),
      'terbayar':        advancePaid.toInt(),
      'taxTotal':        totalTaxes.toInt(),
      'company':         company,
      'catatan':         catatan,
      'sales':           sales,
      'koordinator':     koordinator,
      'opsiPengiriman':  opsiPengiriman,
      'lokasi':          lokasi,

      // ── Address ───────────────────────────────────────────────────────────
      'address': {
        'customerAddress':     customerAddress,
        'shippingAddressName': shippingAddressName,
        'contactPerson':       '-',
        'addressDisplay':      addressDisplay,
      },

      // ── Customer PO ───────────────────────────────────────────────────────
      'customerPO': {
        'number': '-',
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
        'itemCode':      item.itemCode,
        'itemName':      item.itemName,
        'description':   item.description,
        'itemGroup':     item.itemGroup,
        'subKategori':   item.subKategori,
        'kategoriBarang':item.kategoriBarang,
        'qty':           item.qty,
        'deliveredQty':  item.deliveredQty,
        'uom':           item.uom,
        'date':          item.deliveryDate,
        'rate':          item.rate.toInt(),
        'amount':        item.amount.toInt(),
        'warehouse':     item.warehouse,
      }).toList(),

      // ── Taxes ─────────────────────────────────────────────────────────────
      'taxes': taxes.map((t) => {
        'type':        t.type,
        'accountHead': t.accountHead,
        'rate':        t.rate,
        'amount':      t.amount.toInt(),
      }).toList(),

      // ── Payment Schedule ──────────────────────────────────────────────────
      'paymentSchedule': paymentSchedule.map((p) => {
        'paymentTerm':   p.paymentTerm,
        'dueDate':       p.dueDate,
        'paymentAmount': p.paymentAmount.toInt(),
        'outstanding':   p.outstanding.toInt(),
        'paidAmount':    p.paidAmount.toInt(),
      }).toList(),

      // ── Sales Invoice — kosong, SO belum tentu punya SI ───────────────────
      'salesOrders': [],
    };
  }
}