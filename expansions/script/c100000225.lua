--[[
Number 203: Archangel of Verdanse
Numero 203: Arcangelo di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),5,2)
	--[[If this card is Xyz Summoned: You can Special Summon as many "Verdanse" Ritual Monsters from your GY as possible, and if you do,
	until the end of your next turn, all "Verdanse" monsters you currently control cannot be targeted or destroyed by your opponent's card effects,
	also they cannot be Tributed or used as material for the Summon of a monster from the Extra Deck by your opponent.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[When your opponent Special Summons a monster(s) (Quick Effect): You can detach 1 material from this card; until the end of this turn,
	that monster(s) cannot be Tributed or used as material for the Summon of a monster from the Extra Deck, also during the End Phase, shuffle it into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		s.condition,
		aux.DetachSelfCost(),
		s.target,
		s.operation
	)
	c:RegisterEffect(e2)
	--All monsters your opponent controls must attack, if able, also you choose the attack targets for your opponent's attacks.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
end
aux.xyz_number[id]=203

--E1
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VERDANSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetMZoneCount(tp)
	local tg=Duel.Group(aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tg=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
		if #tg==0 then return end
		local c=e:GetHandler()
		local desc=aux.Stringid(id,1)
		local rct=Duel.GetNextPhaseCount(PHASE_END,tp)
		local resets=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_TURN_SELF
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,resets,EFFECT_FLAG_CLIENT_HINT,rct,0,desc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(resets,rct)
			tc:RegisterEffect(e1)
			local e1x=e1:Clone()
			e1x:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e1x)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e2:SetValue(aux.tgoval)
			e2:SetReset(resets,rct)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e3:SetValue(aux.indoval)
			e3:SetReset(resets,rct)
			tc:RegisterEffect(e3)
			aux.CannotBeEDMaterial(tc,s.limval(1-tp),nil,false,{resets,rct},c)
		end
	end
end
function s.limval(p)
	return	function(c)
				return not (c:IsLocation(LOCATION_EXTRA) and current_triggering_player==p)
			end
end

--E2
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards()
	if #tg==0 then return end
	local c=e:GetHandler()
	local desc=aux.Stringid(id,3)
	local resets=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
	local eid=e:GetFieldID()
	Duel.HintSelection(tg)
	for tc in aux.Next(tg) do
		tc:RegisterFlagEffect(id+100,resets,EFFECT_FLAG_CLIENT_HINT,1,eid,desc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(resets,rct)
		tc:RegisterEffect(e1)
		local e1x=e1:Clone()
		e1x:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e1x)
		aux.CannotBeEDMaterial(tc,aux.NOT(aux.FilterBoolFunction(Card.IsLocation,LOCATION_EXTRA)),nil,false,resets,c)
	end
	tg:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,4)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(eid)
	e1:SetLabelObject(tg)
	e1:SetCondition(s.tdcon)
	e1:SetOperation(s.tdop)
	Duel.RegisterEffect(e1,tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local tg=e:GetLabelObject()
	if not tg or not tg:IsExists(Card.HasFlagEffectLabel,1,nil,id+100,eid) then
		if tg then
			tg:DeleteGroup()
		end
		e:Reset()
		return false
	end
	return true
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local eid=e:GetLabel()
	local tg=e:GetLabelObject():Filter(Card.HasFlagEffectLabel,nil,id+100,eid)
	if tg and #tg>0 then
		if tg:IsExists(Card.IsAbleToDeck,1,nil) then
			Duel.Hint(HINT_CARD,tp,id)
		end
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end