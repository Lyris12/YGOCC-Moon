--Tyran du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--[[You can discard up to 2 Ritual Spells, then apply these effects in sequence, depending on the number of cards discarded by this effect.
	● 1+: Special Summon 1 face-up "Vaisseau" monster from your Extra Deck, but negate its effects. (This is treated as a Ritual Summon).
	● 2: Special Summon 1 "Vaisseau" monster from your Deck, ignoring its Summoning conditions, but negate its effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_HANDES|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
	--[[If this card was Ritual Summoned, you can activate this effect during your turn as well.
	Once per opponent's turn (Quick Effect): You can target 1 monster your opponent controls, whose ATK is different from the ATK of a "Vaisseau" monster you control; destroy it.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:OPT()
	e2:SetCondition(aux.VaisseauQECondition)
	e2:SetTarget(s.qetg)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)
end
function s.tgfilter(c)
	return c:IsSpell(TYPE_RITUAL) and c:IsDiscardable(REASON_EFFECT)
end
function s.spfilter(c,e,tp,zonechk)
	if not zonechk then
		return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU)
			and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
	else
		for i=0,6 do
			local zone = (i<5) and 1<<i or (i==5) and 0x200040 or 0x400020
			if c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU)
				and Duel.GetLocationCountFromEx(tp,tp,nil,c,zone)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp,zone) then
				return true
			end
		end
		return false
	end
end
function s.spfilter2(c,e,tp,zone)
	if not zone then
		return c:IsMonster() and c:IsSetCard(ARCHE_VAISSEAU) and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	else
		return c:IsMonster() and c:IsSetCard(ARCHE_VAISSEAU) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,0x6000ff&(~zone))>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then
		return #g>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	local ng=Duel.Group(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	Duel.SetCardOperationInfo(ng,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tgfilter,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
	local max=1
	if #g>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true) then
		max=2
	end
	local ct=Duel.DiscardHand(tp,s.tgfilter,1,max,REASON_EFFECT,nil)
	if ct>=1 then
		local ng=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #ng>0 then
			Duel.BreakEffect()
			if Duel.SpecialSummonNegate(e,ng,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
				ng:GetFirst():CompleteProcedure()
			end
		end
	end
	if ct==2 then
		local ng=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #ng>0 then
			Duel.BreakEffect()
			Duel.SpecialSummonNegate(e,ng,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end

function s.filter(c,tp)
	return c:IsFaceup() and c:HasAttack() and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,c,c:GetAttack())
end
function s.chkfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VAISSEAU) and c:HasAttack() and c:GetAttack()~=atk
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)	
	end
end