--[[
Manaseal Word - Mana
Parola Manasigillo - Mana
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
if not EFFECT_DISABLE_FIELD_ZONE then
	Duel.LoadScript("glitchylib_disablable_field_zones.lua")
end
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Banish 1 Continuous or Field Spell your opponent controls, face-down, until the End Phase. While that card is banished, the Spell & Trap Zone or Field Zone that card was in cannot be used.
	● Return 1 of your banished "Manaseal" monsters to the GY; add 1 "Rank-Up-Magic" or "Remnant" Spell/Trap from your Deck to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If you control "Manaseal Rune Weaving" while this card is in your GY, apply the following effect.
	● Negate the effect of your opponent's second Spell Card or effect that resolves each turn while this effect is applying, and if you do, or if it did not have an effect, banish that card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.negcon2)
	e2:SetOperation(s.negop2)
	c:RegisterEffect(e2)
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToReturnToGraveAsCost(e,tp)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
	end
end
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsSpell(TYPE_CONTINUOUS|TYPE_FIELD) and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT|REASON_TEMPORARY)
end
function s.thfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_REMNANT,ARCHE_RUM) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.rmfilter,tp,0,LOCATION_ONFIELD,nil,tp)
	local b1=#g>0
	local b2=(not e:IsCostChecked() or s.cost2(e,tp,eg,ep,ev,re,r,rp,0)) and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	elseif opt==1 then
		e:SetCategory(CATEGORIES_SEARCH)
		if e:IsCostChecked() then
			s.cost2(e,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
		if #g>0 then
			local tc=g:GetFirst()
			Duel.HintSelection(g)
			local e1,e2,e3=Effect.CreateEffect(c),Effect.CreateEffect(c),Effect.CreateEffect(c)
			if Duel.BanishUntil(tc,e,tp,POS_FACEDOWN,PHASE_END,id,1,false,c,REASON_EFFECT,false,false,nil,nil,{e1,e2})>0 and tc:IsBanished(POS_FACEDOWN) then
				tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,1)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetLabelObject(tc)
				e1:SetCondition(s.discon)
				if tc:IsPreviousLocation(LOCATION_FZONE) then
					e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e1:SetCode(EFFECT_CANNOT_ACTIVATE)
					e1:SetTargetRange(0,1)
					e1:SetValue(function(_e,re,tp)
						return re:GetHandler():IsType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
					end)
					e2:SetType(EFFECT_TYPE_FIELD)
					e2:SetCode(EFFECT_CANNOT_SSET)
					e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e2:SetTargetRange(0,1)
					e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FIELD))
					Duel.RegisterEffect(e2,tp)
					e3:SetType(EFFECT_TYPE_FIELD)
					e3:SetCode(EFFECT_DISABLE_FIELD_ZONE)
					e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
					e3:SetTargetRange(0,1)
					Duel.RegisterEffect(e3,tp)
				elseif tc:IsPreviousLocation(LOCATION_SZONE) then
					e2:Reset()
					e3:Reset()
					local zone=tc:GetPreviousZone(tp)
					e1:SetCode(EFFECT_DISABLE_FIELD)
					e1:SetLabel(zone)
					e1:SetOperation(s.disop)
				end
				Duel.RegisterEffect(e1,tp)
			end
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end
function s.discon(e)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffect(id+100) then
		e:Reset()
		return false
	end
	return true
end
function s.disop(e,tp)
	return e:GetLabel()
end

--E2
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return (not Duel.PlayerHasFlagEffect(tp,id) or Duel.GetFlagEffectLabel(tp,id)<2)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.PlayerHasFlagEffect(tp,id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	end
	Duel.UpdateFlagEffectLabel(tp,id)
	local ct=Duel.GetFlagEffectLabel(tp,id)
	if ct==2 then
		if Duel.IsChainDisablable(ev) then
			Duel.Hint(HINT_CARD,tp,id)
			if Duel.NegateEffect(ev) and rc:IsRelateToChain(ev) then
				Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end