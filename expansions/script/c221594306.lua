--created by Walrus, coded by XGlitchy30
--Voidictator Demon - The Gate Keeper
local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+100
	end
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3,3,s.lcheck)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.LinkSummonedCond)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_REMOVE)
	e2x:SetCondition(s.atkcon2)
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
function s.matfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and c:IsLinkRace(RACE_FIEND)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,ARCHE_VOIDICTATOR)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==5 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,5,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and not c:IsLocation(LOCATION_DECK)
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:HasAttack() and c:IsSetCard(ARCHE_VOIDICTATOR)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,LOCATION_EXTRA)>0 then
		local g=Duel.Group(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			Duel.BreakEffect()
			for tc in aux.Next(g) do
				tc:UpdateATK(1000,RESET_PHASE|PHASE_END,{c,true})
			end
		end
	end
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSummonPlayer(1-tp)
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
