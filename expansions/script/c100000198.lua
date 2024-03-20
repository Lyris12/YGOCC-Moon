--[[
Lorithia, Lumen Knight of Ichyaltas
Lorithia, Cavaliere Lume di Ichyaltas
Card Author: Zerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,s.lcheck)
	--[[If this card is Link Summoned using "Lorithia, Squire of Ichyaltas" as material: You can target 1 face-up card on the field; send it to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(s.tgcon,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--[[During the Main Phase: You can send 1 "Ichyaltas" monster from your Deck to the GY; Special Summon 1 "Ichyaltas Squire Token" (Warrior/EARTH/1000 ATK/1000 DEF)
	with the same Level as the monster sent to your GY, but it cannot be used as Link Material.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORIES_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(aux.MainPhaseCond(),aux.DummyCost,s.tktg,s.tkop)
	c:RegisterEffect(e3)
	--[[If this card is Tributed: You can Special Summon up to 2 "Lorithia, Squire of Ichyaltas" from your GY or that are banished, but they cannot be used as Link Material.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:HOPT()
	e4:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,ARCHE_ICHYALTAS)
end

--E1
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.LinkSummonedCond(e) and e:GetLabel()==1
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOGRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

--E2
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g and g:IsExists(Card.IsLinkCode,1,nil,CARD_LORITHIA_SQUIRE_OF_ICHYALTAS) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end

--E3
function s.tkfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_ICHYALTAS) and c:HasLevel() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ICHYALTAS_SQUIRE,ARCHE_ICHYALTAS,TYPES_TOKEN_MONSTER,1000,1000,c:GetLevel(),RACE_WARRIOR,ATTRIBUTE_EARTH)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExists(false,s.tkfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tkfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SetTargetParam(g:GetFirst():GetLevel())
		Duel.SendtoGrave(g,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=Duel.GetTargetParam()
	if lv and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ICHYALTAS_SQUIRE,ARCHE_ICHYALTAS,TYPES_TOKEN_MONSTER,1000,1000,lv,RACE_WARRIOR,ATTRIBUTE_EARTH) then
		local tk=Duel.CreateToken(tp,TOKEN_ICHYALTAS_SQUIRE)
		tk:SetCardData(CARDDATA_LEVEL,lv)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
		e2:SetValue(1)
		tk:RegisterEffect(e2,true)
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end

--E4
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(CARD_LORITHIA_SQUIRE_OF_ICHYALTAS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GB,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GB)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter),tp,LOCATION_GB,LOCATION_REMOVED,1,math.min(2,ft),nil,e,tp)
	if #g>0 then
		local c=e:GetHandler()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_BE_LINK_MATERIAL)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
			e1:SetValue(1)
			tc:RegisterEffect(e1,true)
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end