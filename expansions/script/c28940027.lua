--Seeking the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
Duel.LoadScript("GLShortcuts.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Deptheaven.AddPendRestrict(c)
	--Scale
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(ref.sctg)
	e1:SetOperation(ref.scop)
	c:RegisterEffect(e1)
	--Swap
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(ref.swapcon)
	e2:SetCost(ref.swapcost)
	e2:SetTarget(ref.swaptg)
	e2:SetOperation(ref.swapop)
	c:RegisterEffect(e2)
	--GY Scale (GYRemove)
	local e3=Deptheaven.EnableGYScale(c,ref.rmtg,ref.rmop)
	e3:SetProperty(Deptheaven.GYScaleProperty+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE)
end
--Scale
function ref.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Deptheaven.Is,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Deptheaven.Is,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
end
function ref.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local e1=Glitchy.SingleEffectGiver(c,tc,EFFECT_CANNOT_REMOVE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	local t={}
	--local p=1
	if c:GetLeftScale()~=2 then t[1]=2 end
	if c:GetLeftScale()~=6 then t[2]=6 end
	--for i=2,6 do if i~=c:GetLeftScale() then t[p]=i p=p+1 end end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Glitchy.SingleEffectGiver(c,c,EFFECT_CHANGE_LSCALE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ac)
	Glitchy.SingleEffectGiver(c,c,EFFECT_CHANGE_RSCALE,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,ac)
end

--Swap
function ref.efilter(re)
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function ref.swapcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==Duel.GetTurnPlayer() and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
function ref.swapcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function ref.setfilter(c,e,tp)
	if not Deptheaven.Is(c) then return false end
	return (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		or (c:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE>1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)) 
end
function ref.swaptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,tp)
end
function ref.flipfilter(c)
	return Deptheaven.Is(c,true) and c:IsFacedown() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
end
function ref.swapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)) then return false end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if sc:IsType(TYPE_SPELL+TYPE_TRAP) then Duel.SSet(tp,sc)
		else if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then Duel.ConfirmCards(1-tp,sc) end 
		end
		Duel.SpecialSummonComplete()
		if Duel.IsExistingMatchingCard(ref.flipfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local fg=Duel.SelectMatchingCard(tp,ref.flipfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
			if #fg>0 then Duel.ChangePosition(fg,POS_FACEUP) end
		end
	end
end

--GYRemove
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function ref.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
