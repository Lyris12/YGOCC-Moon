--[[
Lotus Blade Aesthetic - Azami
Estetica della Lama di Loto - Azami
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control no monsters, you can Special Summon this card (from your hand).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can Set 1 "Lotus Blade" Spell/Trap directly from your Deck or GY, then,
	if you control 2 or more "Lotus Blade" cards, it can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,s.setcost,s.settg,s.setop)
	c:RegisterEffect(e2)
	--[[If this card is in your GY (Quick Effect): You can send 1 "Lotus Blade" card from your hand or field to the GY;
	Special Summon this card, then, if you control 2 or more "Lotus Blade" Spells, draw 1 card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT()
	e3:SetRelevantTimings()
	e3:SetFunctions(nil,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e3)
	--
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(ARCHE_LOTUS_BLADE)
end

--E1
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

--E2
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterHint(tp,id,PHASE_END,1,id,2)
end
function s.splimit(e,c)
	return not c:IsSetCard(ARCHE_LOTUS_BLADE)
end
function s.setfilter(c)
	return c:IsSetCard(ARCHE_LOTUS_BLADE) and c:IsST() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)>0 and tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_LOTUS_BLADE),tp,LOCATION_ONFIELD,0,2,nil) then
		Duel.BreakEffect()
		local code = tc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(STRING_FAST_ACTIVATION)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(code)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

--E3
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_LOTUS_BLADE) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and (Duel.GetMatchingGroupCount(s.spellfilter,tp,LOCATION_ONFIELD,0,c)<2 or Duel.IsPlayerCanDraw(tp,1))
end
function s.spellfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,tp) and s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			return false
		end
		if e:IsCostChecked() then
			return true
		else
			return Duel.GetMZoneCount(tp)>0 and (Duel.GetMatchingGroupCount(s.spellfilter,tp,LOCATION_ONFIELD,0,nil)<2 or Duel.IsPlayerCanDraw(tp,1))
		end
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	if Duel.GetMatchingGroupCount(s.spellfilter,tp,LOCATION_ONFIELD,0,nil)>=2 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetMatchingGroupCount(s.spellfilter,tp,LOCATION_ONFIELD,0,nil)>=2 then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end