--[[
Diabolical Quarphex LV12
Quarphex Diabolico LV12
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--[[All monsters your opponent controls become Level 4, also your opponent cannot activate the effects of Level 4 monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(4)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_FIELD)
	e1x:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1x:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetTargetRange(0,1)
	e1x:SetValue(s.aclimit)
	c:RegisterEffect(e1x)
	--[[Activate only as Chain Link 4 (Quick Effect): You can target 4 cards on the field and/or in the GYs; banish them.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
	--[[If this card is sent to the GY: You can add 1 "Quarphex" card from your Deck or GY to your hand, except "Diabolical Quarphex LV12".]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e3)
end
s.lvup={CARD_DIABOLICAL_QUARPHEX_LV8,id}
s.lvdn={CARD_DIABOLICAL_QUARPHEX_LV4,CARD_DIABOLICAL_QUARPHEX_LV8}

--E1
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLevel(4)
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==3
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,4,4,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards()
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end

--E3
function s.filter(c)
	return c:IsSetCard(ARCHE_QUARPHEX) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
