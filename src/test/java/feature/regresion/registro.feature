
Feature: Registro de usuarios y asignacion de saldo inicial

  Background:
    * def headers = { 'x-channel': 'POSTMAN' }
    * def pin = '123456'
    * def randomPhone =
      """
      function() {
        return '9' + Math.floor(Math.random() * 100000000)
        .toString().padStart(8, '0');
      }
      """

  Scenario: Registrar emisor y receptor
    * def senderPhone = randomPhone()
    Given url _urlAuth
    And path 'auth/v1/register'
    And headers headers
    And request
      """
      {
        phone: '#(senderPhone)',
        fullName: 'Emisor Regresion',
        email: 'email@test.com',
        pin: '#(pin)'
      }
      """
    When method post
    Then status 201
    * def senderId = response.user.id

    * def receiverPhone = randomPhone()
    Given url _urlAuth
    And path 'auth/v1/register'
    And headers headers
    And request
      """
      {
        phone: '#(receiverPhone)',
        fullName: 'Receptor Regresion',
        email: 'email@test.com',
        pin: '#(pin)'
      }
      """
    When method post
    Then status 201
    * def receiverId = response.user.id

    Given url _urlAuth
    And path 'auth/v1/login'
    And headers headers
    And request
      """
      {
        phone: '#(senderPhone)',
        pin: '#(pin)'
      }
      """
    When method post
    Then status 200
    * def senderToken = response.token

    Given url _urlWallet
    And path 'wallet/v1/deposit'
    And headers headers
    And header Authorization = 'Bearer ' + senderToken
    And request { amount: 10000.00 }
    When method post
    Then status 200

    Given url _urlWallet
    And path 'wallet/v1/balance'
    And headers headers
    And header Authorization = 'Bearer ' + senderToken
    When method get
    Then status 200
    * def senderInitialBalance = response.balance
    * match senderInitialBalance == 10000

    Given url _urlAuth
    And path 'auth/v1/login'
    And headers headers
    And request
      """
      {
        phone: '#(receiverPhone)',
        pin: '#(pin)'
      }
      """
    When method post
    Then status 200
    * def receiverToken = response.token

    Given url _urlWallet
    And path 'wallet/v1/deposit'
    And headers headers
    And header Authorization = 'Bearer ' + receiverToken
    And request { amount: 100.00 }
    When method post
    Then status 200

    Given url _urlWallet
    And path 'wallet/v1/balance'
    And headers headers
    And header Authorization = 'Bearer ' + receiverToken
    When method get
    Then status 200
    * def receiverInitialBalance = response.balance
    * match receiverInitialBalance == 100

    * def result =
      """
      {
        senderId: '#(senderId)',
        senderPhone: '#(senderPhone)',
        receiverId: '#(receiverId)',
        receiverPhone: '#(receiverPhone)',
        pin: '#(pin)',
        senderInitialBalance: '#(senderInitialBalance)',
        receiverInitialBalance: '#(receiverInitialBalance)'
      }
      """
