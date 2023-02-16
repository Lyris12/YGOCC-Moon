--Symphaerie Accompaniment, Murr
local ref,id=GetID()
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--Extend Choord
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetCode(EVENT_FREE_CHAIN)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,id)
	pe1:SetCost(ref.sscost)
	pe1:SetTarget(ref.sstg)
	pe1:SetOperation(ref.ssop)
	c:RegisterEffect(pe1)
	--Tunerify
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(ref.lvcon)
	e1:SetTarget(ref.lvtg)
	e1:SetOperation(ref.lvop)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(ref.sccost)
	e2:SetTarget(ref.sctg)
	e2:SetOperation(ref.scop)
	c:RegisterEffect(e2)
end

function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function ref.ssfilter(c,e,tp) return c:IsSetCard(0x255) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) local c,loc=e:GetHandler(),LOCATION_GRAVE
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then loc=loc+LOCATION_DECK end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_PZONE+loc)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp) local c,loc=e:GetHandler(),LOCATION_GRAVE
	if not (c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then loc=loc+LOCATION_DECK end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		g:AddCard(c)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Tunerify
function ref.lvcfilter(c) return c:IsSetCard(0x255) and c:IsFaceup() end --and not c:IsType(TYPE_TUNER) end
function ref.lvcon(e,tp) return Duel.IsExistingMatchingCard(ref.lvcfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
function ref.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(ref.lvcfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,ref.lvcfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function ref.lvop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_TUNER)
	tc:RegisterEffect(e2)
end

--Scale
function ref.sccfilter(c) return c:IsSetCard(0x255) and c:IsAbleToDeckOrExtraAsCost() end
function ref.sccost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(ref.sccfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,2,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.sccfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,2,2,nil)
	g:AddCard(c)
	Duel.HintSelection(g)
	local rg=g:Filter(Card.IsFacedown,nil)
	Duel.ConfirmCards(1-tp,rg)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function ref.scfilter(c)
	return c:IsSetCard(0x255) and c:IsType(TYPE_PENDULUM) and not (c:IsForbidden() or c:IsCode(id))
end
function ref.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(ref.scfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function ref.scop(e,tp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,ref.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
