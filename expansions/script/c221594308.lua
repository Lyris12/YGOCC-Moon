--created by Walrus, coded by XGlitchy30
--Voidictator Deity - Nemesis the Grand Judge
local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+100
	end
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttributeRace,ATTRIBUTE_DARK,RACE_FIEND),aux.NonTuner(Card.IsSetCard,ARCHE_VOIDICTATOR),1)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.SynchroSummonedCond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_REMOVE)
	e2x:SetCondition(s.thcon2)
	c:RegisterEffect(e2x)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,s.progressive_id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,nil,true)
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.HintSelection(g)
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			local codes={tc:GetCode()}
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetLabel(table.unpack(codes))
			e1:SetValue(s.aclimit)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
			Duel.RegisterHint(1-tp,id,PHASE_END,2,id,3)
		end
	end
end
function s.aclimit(e,re,tp)
	local codes={e:GetLabel()}
	return re:GetHandler():IsCode(table.unpack(codes),true)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsLocation(LOCATION_DECK)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToRemove()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 then
		local g=Duel.Group(aux.Necro(s.rmfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
		if #g>=2 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local tg=g:Select(tp,1,3,nil)
			if #tg>0 then
				Duel.HintSelection(tg)
				Duel.BreakEffect()
				Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSummonPlayer(1-tp)
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
