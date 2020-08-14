--created by Seth, coded by Lyris
local cid,id=GetID()
local s,id=GetID()
function s.initial_effect(c)
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_ACTIVATE)
		e0:SetCode(EVENT_FREE_CHAIN)
		c:RegisterEffect(e0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x83e))
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(300)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_FZONE)
		e3:SetCountLimit(1,id)
		e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e3:SetTarget(s.thtg)
		e3:SetOperation(s.ope)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e4:SetRange(LOCATION_FZONE)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(s.indtg)
		e4:SetValue(s.indct)
		c:RegisterEffect(e4)
end
	function s.target(e,c)
	return c:IsSetCard(0x83e)
end
	function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
	function s.thfilter(c)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.ope(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	function s.indtg(e,c)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER)
end
	function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)==0 then return 0 end
	return 1
end
