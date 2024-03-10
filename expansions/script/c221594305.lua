--created by Walrus, coded by XGlitchy30
--Voidictator Servant - Knight of Corvus
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.BanishCost(aux.Filter(Card.IsSetCard,ARCHE_VOIDICTATOR),LOCATION_GRAVE))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.filter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function s.ffilter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_RUNE_COURT_OF_THE_VOID)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		local res,shuffle=false,false
		local b1=tc:IsAbleToHand()
		local b2=tc:IsAbleToRemove()
		local opt=aux.Option(tp,nil,0,{b1,STRING_ADD_TO_HAND},{b2,STRING_BANISH})
		if opt==0 then
			res=Duel.SearchAndCheck(tc,tp)
			shuffle=true
		else
			res=Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		end
		if res and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_FZONE,0,1,nil) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,STRING_ASK_SPECIAL_SUMMON) then
			if shuffle then
				Duel.ShuffleHand(tp)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,LOCATION_MZONE,500)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP,nil,LOCATION_DECKSHF)>0 and c:IsFaceup() then
		c:UpdateATK(500,true,c)
	end
end
