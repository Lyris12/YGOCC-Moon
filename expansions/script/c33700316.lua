--无心械姬的玉碎令
local m=33700316
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+0x1c0)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)	
end
function cm.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1449) and c:IsType(TYPE_MONSTER)
end
function cm.afilter2(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1449) and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.afilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.afilter2,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()<=0 then return end
	local fid=c:GetFieldID()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	g:KeepAlive()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(g)
	e2:SetCondition(cm.descon)
	e2:SetOperation(cm.desop)
	Duel.RegisterEffect(e2,tp)
end
function cm.desfilter(c,fid)
	return c:GetFlagEffectLabel(m)==fid
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(cm.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(cm.desfilter,nil,e:GetLabel())
	local huangjun=dg:GetCount()
	local edg=Duel.GetMatchingGroup(cm.rfilter,tp,LOCATION_ONFIELD,0,dg,e)
	if edg:GetCount()>=huangjun and Duel.SelectEffectYesNo(tp,aux.Stringid(m,0)) then
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	   local ig=edg:Select(tp,huangjun,huangjun,nil)
	   Duel.Hint(HINT_CARD,0,33700316)
	   Duel.Destroy(ig,REASON_EFFECT)
	else
	   Duel.Destroy(dg,REASON_EFFECT)
	end
end
function cm.rfilter(c,e)
	return and c:IsSetCard(0x1449) and c:IsFaceup() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
