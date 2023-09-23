--Crystron Angate
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	--[[Once per turn, if a card(s) on the field is destroyed, even during the Damage Step: You can draw 1 card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY|EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drawcon)
	e1:SetTarget(aux.DrawTarget())
	e1:SetOperation(aux.DrawOperation())
	c:RegisterEffect(e1)
	--[[If this card is Link Summoned: You can add 1 "Crystron" monster from your Deck to your hand, and if you do,
	send 1 "Crystron" monster with a different name from your Deck to the GY, also you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except Machine Synchro Monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.LinkSummonedCond)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--[[During your opponent's turn (Quick Effect): You can send 1 "Crystron" monster from your Deck to the GY, and if you do,
	Special Summon 1 "Crystron Token" (Machine/WATER/Level 1/ATK 0/DEF 0), but it cannot be Tributed, then its Level becomes sent monster's Level.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORIES_TOKEN|CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetRelevantTimings()
	e3:SetCondition(aux.TurnPlayerCond(1))
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
end
--E1
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_ONFIELD)
end

--E2
function s.thfilter(c,tp)
	return c:IsSetCard(ARCHE_CRYSTRON) and c:IsMonster() and c:IsAbleToHand() and (not tp or Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,c,{c:GetCode()}))
end
function s.tgfilter(c,codes)
	return c:IsSetCard(ARCHE_CRYSTRON) and c:IsMonster() and c:IsAbleToGrave() and not c:IsCode(table.unpack(codes))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	end
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		local codes={g:GetFirst():GetCode()}
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,codes)
		if #dg>0 then
			Duel.SendtoGrave(dg,REASON_EFFECT)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterHint(tp,id,PHASE_END,1,id,2)
end
function s.splim(e,c)
	return c:IsLocation(LOCATION_EXTRA) and (not c:IsType(TYPE_SYNCHRO) or not c:IsRace(RACE_MACHINE))
end

--E3
function s.tkfilter(c)
	return c:IsSetCard(ARCHE_CRYSTRON) and c:IsMonster() and c:HasLevel() and c:IsAbleToGrave()
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_CRYSTRON,ARCHE_CRYSTRON,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER)
			and Duel.IsExistingMatchingCard(s.tkfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tkfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		if tc:IsInGY() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_CRYSTRON,ARCHE_CRYSTRON,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER) then
			local c=e:GetHandler()
			local lv=tc:GetLevel()
			local token=Duel.CreateToken(tp,TOKEN_CRYSTRON)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_CANNOT_BE_TRIBUTED)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetProperty(0)
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				token:RegisterEffect(e2,true)
			end
			if Duel.SpecialSummonComplete()>0 and lv and token:GetLevel()~=lv then
				if not token:IsImmuneToEffect(e) then
					Duel.BreakEffect()
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e1)
			end
		end
	end
end