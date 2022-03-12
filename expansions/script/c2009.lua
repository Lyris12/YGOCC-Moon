--Ergoriesumante Fiangelcodice
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	--declare
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--apply
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.namecon)
	e2:SetCost(s.namecost)
	e2:SetTarget(s.nametg)
	e2:SetOperation(s.nameop)
	c:RegisterEffect(e2)
	--immune
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
end
function s.ffilter(c)
	for _,code in ipairs({c:GetCode()}) do
		if code~=c:GetOriginalCode() then
			return true
		end
	end
	return false
end

function s.efilter(e,te)
	local c=te:GetHandler()
	for _,code in ipairs({c:GetCode()}) do
		if code~=c:GetOriginalCode() then
			return true
		end
	end
	return false
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	Duel.SetChainLimit(aux.FALSE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=Duel.GetTargetParam()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	e2:SetLabel(code)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.acon)
	e3:SetOperation(s.aop)
	e3:SetLabel(code)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e3)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:GetHandler():IsCode(e:GetLabel()) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
function s.acon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and re:GetHandler():IsCode(e:GetLabel()) and c:GetFlagEffect(id)~=0
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.Hint(HINT_CARD,0,id)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end

function s.namecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<=0
end
function s.cf(c)
	return c:IsType(TYPE_ST) and (c:IsCode(CARD_ANONYMIZE) or c:IsSetCard(0xca4)) and c:IsAbleToDeckOrExtraAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cf,tp,LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local te=g:GetFirst():CheckActivateEffect(false,true,true)
		s[Duel.GetCurrentChain()]=te
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIONS) and e:GetHandler():IsCode(id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
	end
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=s[Duel.GetCurrentChain()]
	if chkc then
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,true)
	end
	if chk==0 then return true end
	if not te then return end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local te=s[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end