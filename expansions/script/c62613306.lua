--Waltz, la Nottesfumo Ascensione
--Script by XGlitchy30
function c62613306.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x6233),aux.NonTuner(Card.IsSetCard,0x6233),1)
	c:EnableReviveLimit()
	--add or return
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62613306,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62613306)
	e1:SetCondition(c62613306.condition)
	e1:SetTarget(c62613306.target)
	e1:SetOperation(c62613306.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
--filters
function c62613306.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6233) and c:IsControler(tp)
end
function c62613306.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
--special summon
function c62613306.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62613306.cfilter,1,nil,tp)
end
function c62613306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613306.rmfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_REMOVED)
end
function c62613306.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62613306,0))
	local g=Duel.SelectMatchingCard(tp,c62613306.rmfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if not tc then return end
		if tc:IsAbleToHand() and Duel.SelectOption(tp,1190,1191)==0 then
			Duel.SendtoHand(tc,tc:GetOwner(),REASON_EFFECT)
			Duel.ConfirmCards(1-tc:GetControler(),tc)
		else
			Duel.HintSelection(g)
			Duel.SendtoGrave(tc,REASON_EFFECT,tc:GetOwner())
		end
	end
end