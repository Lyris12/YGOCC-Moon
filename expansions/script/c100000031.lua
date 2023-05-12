--Atrocité du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--[[During the Main Phase: You can banish up to 2 cards from the top of your Deck,
	then apply these effects, in sequence, depending on the number of cards banished to the Extra Deck by this effect.
	● 1+:  For the rest of the turn, monsters you control will gain 500 ATK.
	● 2: Place 1 face-up "Vaisseau" Pendulum Monster from your Extra Deck in your Pendulum Zone.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
	--[[● If this card was Ritual Summoned, you can activate this effect during your turn as well.
	During your opponent's turn (Quick Effect): You can shuffle 1 "Vaisseau" Pendulum Monster from your face-up Extra Deck into the Deck;
	monsters your opponent currently controls lose 500 ATK, also their Levels are reduced by 1. These changes apply until the end of the turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCustomCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,RELEVANT_TIMINGS|TIMING_DAMAGE_STEP)
	e2:SetCondition(aux.AND(aux.VaisseauQECondition,aux.ExceptOnDamageCalc))
	e2:SetCost(aux.ToDeckCost(s.cfilter,LOCATION_EXTRA,0,1,1,nil,LOCATION_DECK))
	e2:SetTarget(s.qetg)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetDecktopGroup(tp,2):FilterCount(Card.IsAbleToRemove,nil)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.pcfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,2):Filter(Card.IsAbleToRemove,nil)
	if #g<=0 then return end
	local tab={1}
	if #g==2 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.CheckPendulumZones(tp) then
		table.insert(tab,2)
	end
	Duel.HintMessage(tp,HINTMSG_NUMBER)
	local n=Duel.AnnounceNumber(tp,table.unpack(tab))
	local rg=Duel.GetDecktopGroup(tp,n)
	if #rg>0 then
		local ct=Duel.Banish(rg)
		if ct>=1 then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetValue(500)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
		if ct==2 and Duel.CheckPendulumZones(tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local pg=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			if #pg>0 then
				Duel.BreakEffect()
				Duel.MoveToField(pg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,1-tp,LOCATION_MZONE,-500)
	Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,g,#g,1-tp,LOCATION_MZONE,-1)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(-1)
		tc:RegisterEffect(e2)
	end
end