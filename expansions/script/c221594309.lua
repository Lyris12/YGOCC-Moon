--created by Walrus, coded by XGlitchy30
--Voidictator Demon - The Unending Flame
local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+100
	end
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(aux.XyzSummonedCond,nil,s.attg,s.atop)
	c:RegisterEffect(e2)
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,s.progressive_id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,nil,true)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetFunctions(nil,nil,s.eftg,s.efop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:HOPT()
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	e5:SetCondition(s.spcon2)
	c:RegisterEffect(e5)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND)
end
function s.xyzcheck(g)
	return g:IsExists(Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR)
end
function s.value(e,c)
	return e:GetHandler():GetOverlayCount()*400
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsType(TYPE_XYZ) then
		local g=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,5,nil,tp)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Attach(g,c)
		end
	end
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(1-tp)
end
function s.checkfilter(c)
	return c:IsFaceup() and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.checkfilter,nil)
	if not c:IsRelateToChain() or c:IsFacedown() or #g<=0 then return end
	local tc=g:GetFirst()
	if #g>1 then
		Duel.HintMessage(tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	else
		Duel.HintSelection(Group.FromCards(tc))
	end
	if tc then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsLocation(LOCATION_DECK)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 and Duel.GetMZoneCount(tp)>0
	and Duel.IsExistingMatchingCard(aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
