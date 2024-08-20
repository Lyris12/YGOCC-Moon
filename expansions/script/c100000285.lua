--[[
Spellbook of Forbidden Incantations
Libro di Magia degli Incantesimi Proibiti
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a Spellcaster monster: Take 1 Spellcaster monster from your Deck with a Level equal to or lower than the highest Level among monsters you control,
	and 1 "Spellbook" Normal or Quick-Play Spell, except "Spellbook of Forbidden Incantations", Special Summon that Spellcaster monster, and if you do, equip that "Spellbook" Spell
	to that monster as an Equip Spell that gives it ATK equal to its Level x 300.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		aux.LocationGroupCond(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),LOCATION_MZONE,0),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except during the turn it was sent there: You can target 3 of your banished "Spellbook" Spell/Traps and 1 Level 5 or higher Spellcaster monster in your GY
	or banishment; shuffle those "Spellbook" Spell/Traps into the Deck, and if you do, banish this card, then Special Summon the last target.
	Its effects are negated, also its ATK/DEF becomes 0. (These changes last until the End Phase.)]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(aux.exccon,nil,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
--E1
function s.spfilter(c,e,tp,max)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:HasLevel() and c:IsLevelBelow(max) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExists(false,s.eqfilter,tp,LOCATION_DECK,0,1,c,c,e,tp)
end
function s.eqfilter(c,ec,e,tp)
	return (c:IsNormalSpell() or c:IsSpell(TYPE_QUICKPLAY)) and c:IsSetCard(ARCHE_SPELLBOOK) and not c:IsCode(id) and ec:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(aux.Faceup(Card.HasLevel),tp,LOCATION_MZONE,0,nil)
	local _,max=g:GetMaxGroup(Card.GetLevel)
	if chk==0 then
		local c=e:GetHandler()
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsType(TYPE_FIELD) and not c:IsInBackrow() then
			ft=ft-1
		end
		if #g<=0 or ft<=0 or Duel.GetMZoneCount(tp)<=0 then return false end
		return Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,max)
	end
	local eid=e:GetFieldID()
	Duel.SetTargetParam(eid)
	local g1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,max)
	local tc=g1:GetFirst()
	local g2=Duel.Select(HINTMSG_EQUIP,false,tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,g1,tc,e,tp)
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,eid)
	g1:Merge(g2)
	Duel.SetTargetCard(g1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.GetTargetCards()
	if #g==0 then return end
	local eid=Duel.GetTargetParam()
	local sc=g:Filter(Card.HasFlagEffectLabel,nil,id,eid):GetFirst()
	if sc and sc:IsMonster() and sc:IsRace(RACE_SPELLCASTER) and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		g:RemoveCard(sc)
		local tc=g:GetFirst()
		if tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsSpell() and tc:IsSetCard(ARCHE_SPELLBOOK) and sc:IsCanBeEquippedWith(tc,e,tp,REASON_EFFECT) and Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,sc) then
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(s.atkval)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.atkval(e,c)
	return c:GetLevel()*300
end

--E2
function s.tdfilter(c)
	return c:IsFaceup() and c:IsST() and c:IsSetCard(ARCHE_SPELLBOOK) and c:IsAbleToDeck()
end
function s.spfilter2(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemove() and Duel.IsExists(true,s.tdfilter,tp,LOCATION_REMOVED,0,3,nil) and Duel.IsExists(true,s.spfilter2,tp,LOCATION_GB,0,1,c,e,tp)
	end
	local eid=e:GetFieldID()
	Duel.SetTargetParam(eid)
	local g1=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	g1:ForEach(function(tc) tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,eid) end)
	local g2=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter2,tp,LOCATION_GB,0,1,1,aux.ExceptThis(c),e,tp)
	Duel.SetCardOperationInfo(g1,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
	Duel.SetCardOperationInfo(g2,CATEGORY_SPECIAL_SUMMON)
end
function s.tdcheck(c,eid)
	return c:HasFlagEffectLabel(id+100,eid) and c:IsST() and c:IsSetCard(ARCHE_SPELLBOOK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g<=0 then return end
	local eid=Duel.GetTargetParam()
	local tg=g:Filter(s.tdcheck,nil,eid)
	if #tg>0 and Duel.ShuffleIntoDeck(tg)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
			g:Sub(tg)
			local tc=g:GetFirst()
			if tc and tc:IsMonster() and tc:IsRace(RACE_SPELLCASTER) and tc:IsLevelAbove(5) then
				Duel.BreakEffect()
				Duel.SpecialSummonMod(e,tc,0,tp,tp,false,false,POS_FACEUP,0xff,{SPSUM_MOD_NEGATE,nil,RESET_PHASE|PHASE_END},{SPSUM_MOD_CHANGE_ATKDEF,0,RESET_PHASE|PHASE_END})
			end
		end
	end
end