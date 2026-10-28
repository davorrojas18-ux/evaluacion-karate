
Feature: Regresion de transferencia entre usuarios

  Background:
    * def headers = { 'x-channel': 'POSTMAN' }
    * def users = callonce read('registro.feature')

  Scenario: Transferir 450 y validar saldo del emisor
    Given url _urlAuth
    And path 'auth/v1/login'
    And headers headers
    And request
      """
      {
        phone: '#(users.senderPhone)',
        pin: '#(users.pin)'
      }
      """
    When method post
    Then status 200
    * def senderToken = response.token

    Given url _urlTransaction
    And path 'transaction/v1/transfer'
    And headers headers
    And header Authorization = 'Bearer ' + senderToken
    And request
      """
      {
        recipientId: '#(users.receiverId)',
        amount: 450.00,
        description: 'Pago de Servicios',
        category: 'cat_food_1'
      }
      """
    When method post
    Then status 200
    * def transactionId = response.referenceCode
    * match transactionId == '#string'

    Given url _urlWallet
    And path 'wallet/v1/balance'
    And headers headers
    And header Authorization = 'Bearer ' + senderToken
    When method get
    Then status 200
    * match response.balance == users.senderInitialBalance - 450

    * def transaction = { transactionId: '#(transactionId)' }
    * def transactionFile = karate.write(transaction, 'transaction.json')
    * print 'Archivo creado:', transactionFile

  Scenario: Validar saldo e historial del receptor
    Given url _urlAuth
    And path 'auth/v1/login'
    And headers headers
    And request
      """
      {
        phone: '#(users.receiverPhone)',
        pin: '#(users.pin)'
      }
      """
    When method post
    Then status 200
    * def receiverToken = response.token

    Given url _urlWallet
    And path 'wallet/v1/balance'
    And headers headers
    And header Authorization = 'Bearer ' + receiverToken
    When method get
    Then status 200
    * match response.balance == users.receiverInitialBalance + 450

    * def transaction = read('file:target/transaction.json')

    Given url _urlWallet
    And path 'wallet/v1/transactions'
    And headers headers
    And header Authorization = 'Bearer ' + receiverToken
    When method get
    Then status 200
    * match response[*].referenceCode contains transaction.transactionId
