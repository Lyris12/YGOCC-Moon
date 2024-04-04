--[[
Voidictator Rune - Guiding Eulogy
Runa dei Vuotodespoti - Elogio Ispiratore
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a "Voidictator Deity" monster: Halve the ATK of 1 Special Summoned monster your opponent controls until the end of the turn, and if you do,
	1 "Voidictator" monster gains that lost ATK. If you control a "Voidictator Deity - Omen the Dark Angel", that monster's ATK becomes 0 instead.
	Your opponent cannot activate cards or effects in response to this card's activation if you control "Voidictator Deity - Omen the Dark Angel".]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is banished by a "Voidictator" card you own: You can target 1 "Voidictator Deity" or "Voidictator Demon" monster you control;
	all monsters your opponent currently controls lose ATK equal to the ATK of that monster. If a monster(s) ATK is reduced to 0 by this effect, its effects are negated.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:HOPT()
	e2:SetFunctions(s.setcon,nil,s.settg,s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY)
end
function s.halvefilter(c)
	return c:IsSpecialSummoned() and c:IsCanChangeAttack()
end
function s.gainfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsCanChangeAttack()
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_DEITY_OMEN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.Group(s.halvefilter,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.Group(s.gainfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		return #g1*#g2>0
	end
	if Duel.IsExists(false,s.chfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g1,1,1-tp,LOCATION_MZONE,{0})
	else
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g1,1,1-tp,LOCATION_MZONE,0,OPINFO_FLAG_HALVE)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g2,1,PLAYER_ALL,LOCATION_MZONE,0,OPINFO_FLAG_HIGHER)
	if Duel.IsExists(false,s.chfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.Select(HINTMSG_HALVE_ATKDEF,false,tp,s.halvefilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc1=g1:GetFirst()
	if tc1 then
		Duel.HintSelection(g1)
		local c=e:GetHandler()
		local e1,diff=nil,0
		if Duel.IsExists(false,s.chfilter,tp,LOCATION_ONFIELD,0,1,nil) then
			e1,_,_,diff=tc1:ChangeATK(0,RESET_PHASE|PHASE_END,{c,true})
		else
			e1,_,_,diff=tc1:HalveATK(RESET_PHASE|PHASE_END,{c,true})
		end
		if diff<0 and not tc1:IsImmuneToEffect(e1) then
			local g2=Duel.Select(HINTMSG_ATKDEF,false,tp,s.gainfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			local tc2=g2:GetFirst()
			if tc2 then
				Duel.HintSelection(g2)
				tc2:UpdateATK(-diff,0,{c,true})
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
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON) and c:IsAttackAbove(1)
end
function s.disfilter(c,atk)
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	local g=Duel.Group(Card.IsCanChangeAttack,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0 and Duel.IsExists(true,s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local tg=Duel.Select(HINTMSG_TARGET,true,tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local val=tg:GetFirst():GetAttack()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-val)
	local dg=g:Filter(s.disfilter,nil,val)
	Duel.SetCustomOperationInfo(0,CATEGORY_DISABLE,dg,#dg,1-tp,LOCATION_MZONE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:HasAttack() then
		local val=-tc:GetAttack()
		local g=Duel.Group(Card.IsCanChangeAttack,tp,0,LOCATION_MZONE,nil)
		for sc in aux.Next(g) do
			local e1,diff=sc:UpdateATK(val,0,{c,true})
			if diff<0 and sc:GetAttack()==0 and not sc:IsImmuneToEffect(e1) and sc:IsCanBeDisabledByEffect(e) then
				Duel.Negate(sc,e,0,false,false,TYPE_MONSTER)
			end
		end
	end
end