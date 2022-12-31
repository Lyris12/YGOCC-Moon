--Cherub, Soldato Ængelico || Cherub, Ængelic Soldier
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--spsum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

--special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil,tp,POS_FACEDOWN)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_LEAVE_FIELD_P)
		e1:SetCondition(s.rdcon)
		e1:SetOperation(s.rdprev)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp,POS_FACEDOWN)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetReason()&REASON_REDIRECT==0
end
function s.rdprev(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetDestination()==LOCATION_GRAVE then
		local redirect=Effect.CreateEffect(e:GetHandler())
		redirect:SetType(EFFECT_TYPE_SINGLE)
		redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		redirect:SetCode(EFFECT_CANNOT_TO_GRAVE)
		e:GetHandler():RegisterEffect(redirect)
		Duel.Remove(e:GetHandler(),POS_FACEDOWN,e:GetHandler():GetReason()+REASON_REDIRECT)
		redirect:Reset()
	elseif e:GetHandler():GetDestination()==LOCATION_HAND then
		local redirect=Effect.CreateEffect(e:GetHandler())
		redirect:SetType(EFFECT_TYPE_SINGLE)
		redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		redirect:SetCode(EFFECT_CANNOT_TO_HAND)
		e:GetHandler():RegisterEffect(redirect)
		Duel.Remove(e:GetHandler(),POS_FACEDOWN,e:GetHandler():GetReason()+REASON_REDIRECT)
		redirect:Reset()
	elseif (e:GetHandler():GetDestination()==LOCATION_DECK or e:GetHandler():GetDestination()==LOCATION_EXTRA) then
		local redirect=Effect.CreateEffect(e:GetHandler())
		redirect:SetType(EFFECT_TYPE_SINGLE)
		redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		redirect:SetCode(EFFECT_CANNOT_TO_DECK)
		e:GetHandler():RegisterEffect(redirect)
		Duel.Remove(e:GetHandler(),POS_FACEDOWN,e:GetHandler():GetReason()+REASON_REDIRECT)
		redirect:Reset()
	else
		local redirect=Effect.CreateEffect(e:GetHandler())
		redirect:SetType(EFFECT_TYPE_SINGLE)
		redirect:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		redirect:SetCode(EFFECT_CANNOT_REMOVE)
		e:GetHandler():RegisterEffect(redirect)
		Duel.Remove(e:GetHandler(),POS_FACEDOWN,e:GetHandler():GetReason()+REASON_REDIRECT)
		redirect:Reset()
	end
end

--spsum
function s.cfilter(c,e,tp)
	return c:IsFacedown() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0xae6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,e,tp)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost(POS_FACEDOWN) end
	Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_COST)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local g=eg:Filter(s.cfilter,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINT_SPSUMMON)
	local g=eg:FilterSelect(tp,s.cfilter,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end