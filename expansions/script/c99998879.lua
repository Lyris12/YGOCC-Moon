--[[
Voidictator Rune - Execution of the Divine
Runa dei Vuotodespoti - Esecuzione del Divino
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a face-up "Voidictator Demon - Guardian of Corvus": Banish as many random face-down cards from your opponent's Extra Deck, face-down,
	up to the number of your banished "Voidictator" cards with different names, and if you do, 1 "Voidictator Demon - Guardian of Corvus" you control gains 800 ATK/DEF for each card banished
	by this effect. Also, if you banished 10 or more cards by this effect, halve your opponent's LP. You cannot conduct your Battle Phase during the turn you activate this effect.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings(TIMING_DAMAGE_STEP)
	e1:SetFunctions(s.condition,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is banished by a "Voidictator" card you own: You can target 1 face-up "Voidictator Demon - Guardian of Corvus" you control;
	its ATK/DEF become 0, and if they do, you gain LP equal to that lost DEF, then inflict damage to your opponent equal to half of that lost ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_ATKDEF|CATEGORY_RECOVER|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SHOPT()
	e2:SetFunctions(s.setcon,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS),tp,LOCATION_ONFIELD,0,1,nil) and aux.dscon(e)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.rmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(c,tp,POS_FACEDOWN)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR)
end
function s.cfilter(c)
	return c:IsCode(CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS) and c:IsCanChangeStats()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return Duel.IsExists(false,s.rmfilter,tp,0,LOCATION_EXTRA,1,nil,tp) and Duel.IsExists(false,s.filter,tp,LOCATION_REMOVED,0,1,nil) and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,1,tp,LOCATION_MZONE,800)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_EXTRA,nil,tp)
	if #g<=0 then return end
	local ct=Duel.Group(s.filter,tp,LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)
	if ct<=0 then return end
	local rg=g:RandomSelect(tp,math.min(#g,ct))
	if #rg>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
		local rct=Duel.GetOperatedGroup():FilterCount(aux.BecauseOfThisEffect(e),nil)
		if rct>0 then
			local sg=Duel.Select(HINTMSG_ATKDEF,false,tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				sg:GetFirst():UpdateATKDEF(rct*800,nil,0,{e:GetHandler(),true})
			end
			if rct>=10 then
				Duel.HalveLP(1-tp)
			end
		end
	end
end

--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.statfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS) and c:IsCanChangeStats() and (not c:IsAttack(0) or not c:IsDefense(0))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.statfilter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.statfilter,tp,LOCATION_MZONE,0,1,nil) end
	local tc=Duel.Select(HINTMSG_ATKDEF,true,tp,s.statfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,tc,1,tc:GetControler(),tc:GetLocation(),{0})
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,tc:GetDefense())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(tc:GetAttack()/2))
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local e1,e2,_,natk,_,ndef,atkdiff,defdiff=tc:ChangeATKDEF(0,0,0,{e:GetHandler(),true})
		if tc:HasDefense() and ndef==0 and defdiff<0 and not tc:IsImmuneToEffect(e2) and Duel.Recover(tp,-defdiff,REASON_EFFECT)>0
			and tc:HasAttack() and natk==0 and atkdiff<0 and not tc:IsImmuneToEffect(e1) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,-atkdiff/2,REASON_EFFECT)
		end
	end
end