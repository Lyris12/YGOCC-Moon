--Discovery at Peach Beach
function c69012.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69012)
	e1:SetTarget(c69012.thtg)
	e1:SetOperation(c69012.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c69012.fetg)
	e2:SetOperation(c69012.feop)
	c:RegisterEffect(e2)
end
function c69012.revealed(c)
    return c:IsSetCard(0x6969) and c:IsPublic()
end
function c69012.thfilter(c)
    return c:IsSetCard(0x6969) and c:IsAbleToHand()
end
function c69012.thop(e,tp,eg,ep,ev,re,r,rp)
    local rev=Duel.GetMatchingGroup(c69012.revealed,tp,LOCATION_HAND,0,nil)
    local ct=rev:GetCount()
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    if ct>0 then Duel.Recover(p,ct*500,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c69012.thfilter,tp,LOCATION_DECK,0,1,1,nil,rev)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c69012.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local rev=Duel.GetMatchingGroupCount(c69012.revealed,tp,LOCATION_HAND,0,nil)
    if chk==0 then return rev>0 end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c69012.field(c)
return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
 function c69012.fetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c69012.field,tp,LOCATION_DECK,0,1,nil) end
	end
	function c69012.feop(e,tp,eg,ep,ev,re,r,rp)
     Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
     local g=Duel.SelectMatchingCard(tp,c69012.field,tp,LOCATION_DECK,0,1,1,nil)
     if g:GetCount()>0 then
         Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
 end