--created by Seth, coded by Lyris
--Great London Police Inspector Melvin
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.lfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SHOPT()
	e1:SetDescription(1131)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		s[0]=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetDescription(1150)
	e2:SetCondition(s.actcon)
	e2:SetCost(s.actcost)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
end
function s.lfilter(c)
	return c:IsSetCard(0xd3f) and not c:IsCode(id)
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsPreviousControler(1-tp) and c:IsReason(REASON_COST)
end
function s.checkop(e,tp,eg)
	local cid=Duel.GetCurrentChain()
	if cid>0 and eg:IsExists(s.filter,1,nil,tp) then s[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID) end
end
function s.discon(e,tp,_,_,ev,_,_,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and rp==1-tp and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==s[0]
		and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.AnnounceType(tp))
end
function s.disop(e,tp,_,_,ev,re)
	local ec=re:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<1 then return end
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	Duel.ConfirmDecktop(tp,1)
	if not (tc:IsType(1<<e:GetLabel()) and Duel.NegateEffect(ev) and ec:IsRelateToEffect(re)
		and re:GetHandler():IsAbleToChangeControler()) or ec:IsImmuneToEffect(e)
		or Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)<1 then return end
	if not Duel.MoveToField(ec,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	ec:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(id//10-1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
	ec:RegisterEffect(e2)
end
function s.actcon()
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1d3f) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_SZONE)
		and c:GetSequence()<5 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
function s.actcost(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.Remove(Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp),POS_FACEUP,REASON_COST)
end
function s.afilter(c,tp)
	if not c:IsSetCard(0x1d3f) then return false end
	for _,e in ipairs{c:GetActivateEffect()} do if e:IsActivatable(tp,true,true) then return true end end
	return false
end
function s.acttg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.actop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.afilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	local t,te={tc:GetActivateEffect()}
	if #t>1 then
		local ops={}
		for i,ef in ipairs(t) do table.insert(ops,{ef:IsActivatable(),ef:GetDescription(),ef}) end
		te=aux.SelectFromOptions(tp,table.unpack(ops))
	elseif #t>0 then te=t[1]:IsActivatable(tp) and t[1] end
	if not te then return end
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	te:UseCountLimit(tp,1,true)
	local tep=tc:GetControler()
	local cost=te:GetCost()
	if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
end
