--Starflare Knight
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterBoolFunction(Card.IsCode,81455580),1,1,Card.IsNegative,1)
	aux.AddCodeList(c,81455580)
	aux.AddMaterialCodeList(c,81455580)
	--If this card is Bigbang Summoned: You can destroy Spell/Trap cards your opponent controls, up to the number of monsters used to Bigbang Summon this card, 
	--then you can Special Summon 1 "Cosmo'n" monster from your Deck, and if you do, this card gains 200 ATK/DEF for each card destroyed by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--If a Bigbang Monster(s) is Special Summoned to your field: You can shuffle up to 5 "Cosmo'n" cards and/or Psychic monsters from your GY into the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.material_setcode=0xcf11
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetHandler():GetMaterialCount()
		local dt=Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_ONFIELD,nil)
		--Debug.Message(dt)
		return dt>0
	end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xcf11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	--Debug.Message(#g)
	--Debug.Message(ct)
	if ct>0 and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,ct,nil)
		Duel.HintSelection(dg)
		local des=Duel.Destroy(dg,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if des>0 and g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(200*des)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
				c:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				e2:SetValue(200*des)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
				c:RegisterEffect(e2)
			end
		end
	end
end
function s.filter2(c,tp)
	return c:IsType(TYPE_BIGBANG) and c:IsControler(tp)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and (c:IsSetCard(0xcf11) or (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO)))
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter2,1,e:GetHandler(),tp) --and #eg==1
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,5,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end