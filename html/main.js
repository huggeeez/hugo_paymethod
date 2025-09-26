let currentHasBankCard = false;

function setPaymentPrice(price, resourceName, hasBankCard = false) {
    window.currentPrice = price;
    currentHasBankCard = hasBankCard;
    
    document.getElementById('paymentBackground').style.display = 'block';
    document.getElementById('paymentWindow').style.display = 'block';

    const cardButton = document.querySelector('button[onclick="selectPaymentMethod(\'card\')"]');
    if (cardButton) {
        if (!hasBankCard) {
            cardButton.style.opacity = '1';
            cardButton.style.cursor = 'pointer';
            cardButton.title = 'You need a bank card to use this payment method.';
        } else {
            cardButton.style.opacity = '1';
            cardButton.style.cursor = 'pointer';
            cardButton.title = '';
        }
    }
}

window.addEventListener('message', function(event) {
    if (event.data.action === 'setPaymentPrice') {
        setPaymentPrice(event.data.data, event.data.resourceName, event.data.hasBankCard);
    }
});

function cancelPayment() {
    fetch(`https://${GetParentResourceName()}/cancelPayment`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    });

    document.getElementById('paymentBackground').style.display = 'none';
    document.getElementById('paymentWindow').style.display = 'none';
    document.getElementById('cardSelection').style.display = 'none';
}

window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        cancelPayment();
    }
});

function openCardSelection(cards) {
    document.getElementById('paymentWindow').style.display = 'none';
    document.getElementById('cardSelection').style.display = 'block';

    const buttonsContainer = document.getElementById('buttons');
    buttonsContainer.innerHTML = '';

    cards.forEach(card => {
        const button = document.createElement('button');
        button.textContent = `${card.name} (${card.number})`;        button.onclick = () => selectCard({
            account: card.account,
            name: card.name,
            number: card.number
        });
        buttonsContainer.appendChild(button);
    });
}


function selectCard(card) {
    fetch(`https://${GetParentResourceName()}/selectPaymentMethod`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            method: 'card',
            price: window.currentPrice,
            card: card
        })
    });

    document.getElementById('paymentBackground').style.display = 'none';
    document.getElementById('cardSelection').style.display = 'none';
}

function selectPaymentMethod(method) {
    if (method === 'card' && !currentHasBankCard) {
        fetch(`https://${GetParentResourceName()}/showNotification`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: 'You don\'t have a bank card on you!',
            })
        });
        return;
    }
    if (method === 'card') {
        fetch(`https://${GetParentResourceName()}/getPlayerCards`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(response => response.json())
        .then(cards => {
            openCardSelection(cards);
        });
    } else {
        fetch(`https://${GetParentResourceName()}/selectPaymentMethod`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                method: method,
                price: window.currentPrice
            })
        });
        document.getElementById('paymentBackground').style.display = 'none';
        document.getElementById('paymentWindow').style.display = 'none';
    }
}
