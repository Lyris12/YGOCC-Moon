--Converguard Peacechanter
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	Converguard.EnableTimeleap(c,4)

	--Pend
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(aux.TimeleapSummonedCond)
	e1:SetTarget(ref.extg)
	e1:SetOperation(ref.exop)
	c:RegisterEffect(e1)
	--ED Rip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCondition(ref.grcon)
	e2:SetTarget(ref.grtg)
	e2:SetOperation(ref.grop)
	c:RegisterEffect(e2)
end

--Pend
function ref.grfilter(c,tp)
	local loc=(LOCATION_DECK|LOCATION_REMOVED)-c:GetLocation()
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and Duel.IsExistingMatchingCard(ref.exfilter,tp,loc,0,1,nil,c)
end
function ref.exfilter(c,grc)
	return Converguard.Is(c) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (Converguard.Is(grc) or (c:GetOriginalAttribute()==grc:GetOriginalAttribute()))
end
function ref.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetLocation())
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function ref.exop(e,tp)
	local grc=e:GetLabelObject()
	local loc=(LOCATION_DECK|LOCATION_REMOVED)-e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.exfilter,tp,loc,0,1,1,nil,grc)
	if #g>0 then Duel.SendtoExtraP(g,nil,REASON_EFFECT) end
end
--[[function ref.pndfilter(c) return Converguard.Is(c) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
function ref.pndtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.pndfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
end
function ref.rmfilter(c) return Converguard.Is(c) and c:IsAbleToRemove() end
function ref.pndop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,ref.pndfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT) and Duel.IsExistingMatchingCard(ref.rmfilter,tp,LOCATION_EXTRA,0,1,g:GetFirst()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,ref.rmfilter,tp,LOCATION_EXTRA,0,1,1,g:GetFirst())
		if #rg>0 then Duel.BreakEffect() Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) end
	end
end]]

--ED Rip
function ref.grcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if chk==0 then return c:GetFlagEffect(id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_EXTRA)
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function ref.grop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:GetAttack()<1000 or not c:IsRelateToEffect(e)
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA):Select(1-tp,1,1,nil)
	if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
	end
end
