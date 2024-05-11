--[[
Angel of Verdanse
Angelo di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id,CARD_RUM_RITUAL_OF_VERDANSE)
	--[[If this card is Special Summoned: You can target 2 "Verdanse" cards in your GY; add those targets to your hand, then, if you do not have any banished card,
	immediately after this effect resolves, you can Special Summon 1 Level 5 "Verdanse" Ritual Monster from your Deck, except "Angel of Verdanse". (This is treated as a Ritual Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop(0))
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can banish 1 Spell from your GY; banish 1 card your opponent controls, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(aux.MainPhaseCond(),
		aux.BanishCost(aux.FilterBoolFunction(Card.IsSpell),LOCATION_GRAVE),
		s.rmtg,
		s.rmop)
	c:RegisterEffect(e2)
	--[[While this card is attached to a DARK "Number" Xyz Monster as a material, that monster gains the following effect.
	● Your opponent cannot Special Summon monsters in the same column as this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_MUST_USE_MZONE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.limcond)
	e3:SetValue(s.limtg)
	c:RegisterEffect(e3)
	if not aux.EnableSpecialSummonForcedZoneCheck then
		aux.EnableSpecialSummonForcedZoneCheck=true
		
		local f1, f2, f3, f4 = Card.IsCanBeSpecialSummoned, Duel.SpecialSummon, Duel.SpecialSummonStep, Duel.IsPlayerAffectedByEffect
		
		Card.IsCanBeSpecialSummoned = function(C,e,sumtype,sump,ign1,ign2,...)
			aux.SpecialSummonForcedZoneCheck = true
			local res=f1(C,e,sumtype,sump,ign1,ign2,...)
			aux.SpecialSummonForcedZoneCheck = false
			return res
		end
		
		Duel.SpecialSummon = function(g,sumtype,sump,recp,ign1,ign2,pos,...)
			aux.SpecialSummonForcedZoneCheck = true
			local res=f2(g,sumtype,sump,recp,ign1,ign2,pos,...)
			aux.SpecialSummonForcedZoneCheck = false
			return res
		end
		
		Duel.SpecialSummonStep = function(g,sumtype,sump,recp,ign1,ign2,pos,...)
			aux.SpecialSummonForcedZoneCheck = true
			local res=f3(g,sumtype,sump,recp,ign1,ign2,pos,...)
			aux.SpecialSummonForcedZoneCheck = false
			return res
		end
	end
end
--E1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_VERDANSE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExists(true,s.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	local g=Duel.Select(HINTMSG_ATOHAND,true,tp,s.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsLevel(5) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.thop(mode)
	if mode==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local g=Duel.GetTargetCards():Filter(s.thfilter,nil)
					if #g>0 and Duel.SearchAndCheck(g,tp) and Duel.GetBanishmentCount(tp)==0 then
						aux.ApplyEffectImmediatelyAfterResolution(s.thop(1),e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
					end
				end
	
	elseif mode==1 then
		return	function(e,tp,eg,ep,ev,re,r,rp,ce)
					if Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
						local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
						if #g>0 then
							local tc=g:GetFirst()
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetCode(EFFECT_SPSUMMON_PROC)
							e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
							e1:SetRange(LOCATION_DECK)
							e1:SetCondition(s.spcon)
							e1:SetValue(SUMMON_TYPE_RITUAL+id)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD)
							tc:RegisterEffect(e1,true)
							aux.RegisterResetAfterSpecialSummonRule(tc,tp,e1)
							Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_RITUAL+id)
							if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
						end
					end
				end
	end
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetMZoneCount(tp)>0
end

--E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveFacedown,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

--E3
function s.limcond(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.limtg(e)
	local h=e:GetHandler()
	if aux.SpecialSummonForcedZoneCheck or aux.SpSummonProcCard~=nil or aux.SpSummonProcGCard~=nil then
		return 0x7f007f&(~h:GetColumnZone(LOCATION_MZONE))
	else
		return 0x7f007f
	end
end