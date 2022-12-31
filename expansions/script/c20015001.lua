--Pastel Palettes - Hina
--Script by XyLeN
function c20015001.initial_effect(c)
	--sp summon
	c:RegisterEffect(aux.AddPastelPalettesSpSummonEffect(c,20015001,aux.Stringid(20015001,0)))
	--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20015001,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,20015001+200)
	e1:SetTarget(c20015001.tgtg)
	e1:SetOperation(c20015001.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone() 
	e2:SetCode(EVENT_SPSUMMON_SUCCESS) 
	c:RegisterEffect(e2)
end
function c20015001.tgfilter(c)
	return aux.LvL6or7Check(c) and c:IsAbleToGrave()
end
function c20015001.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20015001.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c20015001.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c20015001.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

dofile("script/Pastel Palettes Core.lua")