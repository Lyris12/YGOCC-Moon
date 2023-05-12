--Princesse du Vaisseau
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_EXTRA)
	--You cannot Special Summon monsters, except Insect monsters.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_PZONE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	c:RegisterEffect(e0)
	--[[During your Main Phase: You can add up to 2 "Vaisseau" Pendulum Monsters you control to your Extra Deck face-up, then apply these effects in sequence, depending on the number of cards added to the Extra Deck by this effect.
	● 1+: Negate the effects of 1 card on the field
	● 2: Once during this turn, you can make all "Vaisseau" monsters you currently control unaffected by an opponent's activated effect]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOEXTRA|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterVaisseauPendulumEffectFlag(c,e1)
	--[[If this card is Special Summoned: You can add 1 "Vaisseau" monster from your Deck to your hand,
	also, if this card was Ritual Summoned, you can add 1 "Vaisseau" Ritual Spell from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.qetg)
	e2:SetOperation(s.qeop)
	c:RegisterEffect(e2)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end

function s.tefilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_VAISSEAU) and not c:IsForbidden()
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.tefilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0 and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetCardOperationInfo(g,CATEGORY_TOEXTRA)
	local ng=Duel.Group(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetCardOperationInfo(ng,CATEGORY_DISABLE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.tefilter,tp,LOCATION_MZONE,0,nil)
	if #g<=0 then return end
	local max=1
	if #g>=2 then
		max=2
	end
	local rg=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.tefilter,tp,LOCATION_MZONE,0,1,max,nil)
	if #rg>0 then
		Duel.HintSelection(rg)
		if Duel.SendtoExtraP(rg,tp,REASON_EFFECT)>0 then
			local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
			if ct>=1 then
				local ng=Duel.Select(HINTMSG_DISABLE,false,tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #ng>0 then
					Duel.HintSelection(ng)
					Duel.BreakEffect()
					Duel.Negate(ng:GetFirst(),e)
				end
			end
			if ct==2 then
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:Desc(2)
				e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_SOLVING)
				e1:SetCondition(s.immcon)
				e1:SetOperation(s.immop)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActivated()
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.PlayerHasFlagEffect(tp,id) and c:AskPlayer(tp,3) then
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
		Duel.Hint(HINT_CARD,0,id)
		local eid=re:GetFieldID()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_VAISSEAU))
		e1:SetLabel(eid)
		e1:SetLabelObject(re)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.resetop)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.efilter(e,re)
	return re==e:GetLabelObject() and re:GetFieldID()==e:GetLabel()
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	if re==e1 and re:GetFieldID()==e1:GetLabel() then
		Duel.ResetFlagEffect(tp,id)
		e1:Reset()
		e:Reset()
	end
end

function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.cfilter2(c)
	return c:IsSpell(TYPE_RITUAL) and c:IsSetCard(ARCHE_VAISSEAU) and c:IsAbleToHand()
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsRitualSummoned() then
		local g2=Duel.Group(aux.Necro(s.cfilter2),tp,LOCATION_GRAVE,0,nil)
		if #g2>0 and c:AskPlayer(tp,4) then
			Duel.HintMessage(tp,HINTMSG_ATOHAND)
			local sg=g2:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.Search(sg,tp)
			end
		end
	end
end