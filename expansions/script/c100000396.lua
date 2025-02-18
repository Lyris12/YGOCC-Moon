--[[
Contract with the Lich King
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 monster in your GY; send 1 monster from your hand, field, or Deck with at least 2 of the following that are the same as that target, but with a different original name, and if you do,
	Special Summon that target.
	● Attribute
	● Type
	● ATK
	● DEF]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,c,tp,c:GetAttribute(),c:GetRace(),c:GetAttack(),c:HasDefense(),c:GetDefense(),c:GetOriginalCodeRule())
end
function s.tgfilter(c,tp,attr,race,atk,hasdef,def,...)
	if not (c:IsFaceupEx() and c:IsMonster() and c:IsAbleToGrave() and not c:IsOriginalCodeRule(...) and Duel.GetMZoneCount(tp,c)>0) then return false end
	local ct=0
	for i=1,4 do
		local res=false
		if i==1 then
			res=c:IsAttribute(attr)
		elseif i==2 then
			res=c:IsRace(race)
		elseif i==3 then
			res=c:IsAttack(atk)
		elseif i==4 then
			res=hasdef and c:IsDefense(def)
		end
		if res then
			ct=ct+1
			if ct==2 then
				return true
			end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsControler(tp) and tc:IsMonster() then
		local sc=Duel.Select(HINTMSG_TOGRAVE,false,tp,aux.Necro(s.tgfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,1,nil,tp,tc:GetAttribute(),tc:GetRace(),tc:GetAttack(),tc:HasDefense(),tc:GetDefense(),tc:GetOriginalCodeRule()):GetFirst()
		if sc and Duel.SendtoGraveAndCheck(sc) and Duel.GetMZoneCount(tp)>0 and tc:IsRelateToChain() then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end