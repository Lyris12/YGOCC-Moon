--False Reality Nightmare
local s,id=GetID()
function s.initial_effect(c)
		--Activate
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_ACTIVATE)
		e0:SetCode(EVENT_FREE_CHAIN)
		c:RegisterEffect(e0)
		--change name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetRange(LOCATION_DECK+LOCATION_GRAVE)
		e1:SetValue(195208413)
		c:RegisterEffect(e1)
		--cannot be trg
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetRange(LOCATION_FZONE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetTarget(s.target)
		e2:SetValue(s.evalue)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		c:RegisterEffect(e3)
		--boosts
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetRange(LOCATION_FZONE)
		e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x83e))
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetValue(300)
		c:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e5)
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_IGNITION)
		e6:SetRange(LOCATION_FZONE)
		e6:SetCountLimit(1,id)
		e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e6:SetTarget(s.thtg)
		e6:SetOperation(s.ope)
		c:RegisterEffect(e6)
end
	function s.target(e,c)
	return c:IsSetCard(0x83e)
end
	function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
	function s.thfilter(c)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.ope(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
	