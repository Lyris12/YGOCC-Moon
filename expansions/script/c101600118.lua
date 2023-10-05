--Signer Dragon's Guidance
--Guida del Drago Prescelto
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Add 1 "Signer Dragon" monster from your Deck or GY to your hand, and if you do, banish 1 "Signer Dragon" monster from your GY with the same Attribute as the added monster.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.thfilter(c,chk)
	return c:IsMonster() and c:IsSetCard(0xcd01) and c:IsAbleToHand() and (not chk or Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,c,c:GetAttribute()))
end
function s.rmfilter(c,attr)
	return c:IsMonster() and c:IsSetCard(0xcd01) and c:IsAttribute(attr) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,true) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.ForcedSelect(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,true)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil,g:GetFirst():GetAttribute())
		if #rg>0 then
			Duel.Banish(rg)
		end
	end
end