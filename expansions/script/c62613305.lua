--Shalia, la Nottesfumo Ascensione
--Script by XGlitchy30
function c62613305.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6233),aux.NonTuner(Card.IsSetCard,0x6233),1,1)
	c:EnableReviveLimit()
	--set or mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613305,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62613305)
	e1:SetCondition(c62613305.condition)
	e1:SetTarget(c62613305.target)
	e1:SetOperation(c62613305.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
--filters
function c62613305.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6233) and c:IsControler(tp)
end
function c62613305.filter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x6233) and ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable()) or c:IsAbleToGrave())
end
--special summon
function c62613305.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62613305.cfilter,1,nil,tp)
end
function c62613305.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613305.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c62613305.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62613305,0))
	local g=Duel.SelectMatchingCard(tp,c62613305.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if not tc then return end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsSSetable() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,aux.Stringid(62613305,1),1191)==0) then
			Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end