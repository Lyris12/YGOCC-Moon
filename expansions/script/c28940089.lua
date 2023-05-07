--Monkastery Adherent
local ref,id=GetID()
Duel.LoadScript("Monkastery.lua")
function ref.initial_effect(c)
	local _,e1=Monkastery.SharedEffects(c)
	--Blink
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(ref.bktg)
	e1:SetOperation(ref.bkop)
	c:RegisterEffect(e1)
	--Match Banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(ref.rmtg)
	e2:SetOperation(ref.rmop)
	c:RegisterEffect(e2)
end

--Blink
function ref.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
function ref.bktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(ref.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,ref.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function ref.bkop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_REMOVE)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetTarget(ref.sstg)
		e1:SetOperation(ref.ssop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_REMOVE+RESET_LEAVE))
		tc:RegisterEffect(e1)
		if (Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)<1) then e1:Reset() end
	end
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
end
function ref.ssop(e,tp) local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Match Banish
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	local loc=c:GetPreviousLocation()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,loc,1,nil) end
	local g=Duel.GetFieldGroup(tp,0,loc)
	e:SetLabel(loc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function ref.rmop(e,tp)
	local loc=e:GetLabel()
	local g=Duel.GetFieldGroup(tp,0,loc):Filter(Card.IsAbleToRemove,nil)
	if #g<1 then return end
	local sg=nil
	if (loc==LOCATION_DECK) or (loc==LOCATION_HAND) then
		sg=g:RandomSelect(tp,1)
	else
		sg=g:Select(tp,1,1,nil)
	end
	Duel.HintSelection(sg)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
