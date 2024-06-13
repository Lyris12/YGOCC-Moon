--[[
Curseflame Tormentor Arido
Tormentatore Fiammaledetta Arido
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase: You can remove 2 Curseflame Counters from anywhere on the field, OR banish 1 "Curseflame" card from your GY; Special Summon this card from your hand, and if you do, negate the effects of 1 other face-up card on the field until the end of this turn, then place 1 Curseflame Counter on that card. This is a Quick Effect if your opponent controls a face-up card(s) that has a Curseflame Counter(s).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DISABLE|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(aux.MainPhaseCond(),s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	e1:QuickEffectClone(c,s.qecond)
	--Your opponent cannot activate the effects of a face-up card on the field that has a Curseflame Counter, unless they pay 300 LP x the number of Curseflame Counters on that card.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetFunctions(nil,s.costchk,s.actarget,s.costop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:HasCounter(COUNTER_CURSEFLAME)
end
function s.qecond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.cfilter,tp,0,LOCATION_ONFIELD,1,nil)
end
function s.rmfilter(c,tp)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExists(false,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,true)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetMZoneCount(tp)>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,2,REASON_COST)
	local b2=Duel.IsExists(false,s.rmfilter,tp,LOCATION_GRAVE,0,1,c,tp)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,2,REASON_COST)
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,c,tp)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
	end
end
function s.disfilter(c,ctchk)
	return aux.NegateAnyFilter(c) and (not ctchk or c:IsCanAddCounter(COUNTER_CURSEFLAME,1))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or (Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,true)))
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_CURSEFLAME)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.ForcedSelect(HINTMSG_DISABLE,false,tp,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,true)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local _,_,res=Duel.Negate(tc,e,RESET_PHASE|PHASE_END,false,false,TYPE_NEGATE_ALL)
			if res and tc:IsCanAddCounter(COUNTER_CURSEFLAME,1) then
				Duel.BreakEffect()
				tc:AddCounter(COUNTER_CURSEFLAME,1)
			end
		end
	end
end

--E2
function s.actarget(e,te,tp)
	local tc=te:GetHandler()
	return tc and tc:IsOnField() and tc:IsFaceup() and tc:HasCounter(COUNTER_CURSEFLAME)
end
function s.costchk(e,te,tp)
	local tc=te:GetHandler()
	local val=tc:GetCounter(COUNTER_CURSEFLAME)*300
	local res=Duel.CheckLPCost(tp,val)
	if res then
		e:SetLabelObject(tc)
		return true
	end
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,e:GetLabelObject():GetCounter(COUNTER_CURSEFLAME)*300)
end