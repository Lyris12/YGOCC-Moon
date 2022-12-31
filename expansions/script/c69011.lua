--Peach Beach Trio
function c69011.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69011)
	e1:SetTarget(c69011.gytg)
	e1:SetOperation(c69011.gyop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c69011.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c69011.thtg)
	e2:SetOperation(c69011.thop)
	c:RegisterEffect(e2)
 end
function c69011.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6969) and c:IsAbleToHand()
end
function c69011.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c81191584.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c690111.filter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c69011.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function c69011.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
function c69011.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local rev=Duel.GetMatchingGroupCount(c69011.revealed,tp,LOCATION_HAND,0,nil)
    if chk==0 then return rev>0 end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(rev*500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rev*500)
end
function c69011.thcon(e,tp)
    return Duel.GetLP(tp)>Duel.GetLP(1-tp) and aux.exccon(e)
end
function c69011.thop(e,tp,eg,ep,ev,re,r,rp)
    local rev=Duel.GetMatchingGroup(c69011.revealed,tp,LOCATION_HAND,0,nil)
    local ct=rev:GetCount()
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if d<(ct*500) then ct=d end
    if Duel.Recover(p,ct*500,REASON_EFFECT)<=0 then return end
    if ct>3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,c69011.thfilter,tp,LOCATION_DECK,0,1,1,nil,rev)
        if g:GetCount()>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end
function c69011.revealed(c)
    return c:IsSetCard(0x6969) and c:IsPublic()
end
function c69011.thfilter(c,g)
    tc=g:GetFirst()
    same=false
    while tc and not same do
        if tc:GetCode()==c:GetCode() then same=true end
        tc=g:GetNext()
    end
    return c:IsSetCard(0x6969) and c:IsAbleToHand() and not same
end