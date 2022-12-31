--Legends and Myths, Castle Regalia
local s,id=GetID()
function s.initial_effect(c)
	--add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={0x190}
function s.chainfilter(re,tp,cid)
	return (not(re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0xFA0)) or (re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsSetCard(0x190)))
end
function s.filter1(c)
	return c:IsSetCard(0xFA0) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:GetLevel()==4
end
function s.filter2(c)
	return c:IsSetCard(0xFA0) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:GetLevel()==5
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 then return end
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and g2:GetCount()>0 and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		local sg2=g2:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		local tc2=sg2:GetFirst()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and Duel.SendtoHand(tc2,nil,REASON_EFFECT)~=0 then 
		Duel.ConfirmCards(1-tp,tc)
		Duel.ConfirmCards(1-tp,tc2)
			local e0=Effect.CreateEffect(e:GetHandler())
			e0:SetType(EFFECT_TYPE_FIELD)
			e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
			e0:SetCode(EFFECT_CANNOT_ACTIVATE)
			e0:SetReset(RESET_PHASE+PHASE_END)
			e0:SetTargetRange(1,0)
			e0:SetTarget(s.aclimit0)
			Duel.RegisterEffect(e0,tp)
			aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.sumlimit)
			e1:SetLabel(tc:GetCode())
			e1:SetValue(s.aclimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			Duel.RegisterEffect(e2,tp)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_ACTIVATE)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetTargetRange(1,0)
			e3:SetTarget(s.sumlimit)
			e3:SetLabel(tc2:GetCode())
			e3:SetValue(s.aclimit)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_CANNOT_TRIGGER)
			Duel.RegisterEffect(e4,tp)
		end
	end
end
function s.aclimit0(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and (not re:GetHandler():IsSetCard(0xFA0) or not re:GetHandler():IsSetCard(0x190))
end
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsCode(e:GetLabel()) and ((re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and not re:IsHasType(EFFECT_TYPE_ACTIVATE)) or (re:GetActiveType()==TYPE_PENDULUM+TYPE_MONSTER and re:IsHasType(EFFECT_TYPE_TRIGGER)) or re:IsHasType(EFFECT_TYPE_IGNITION))
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xFA0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsFaceup() and c:IsLocation(LOCATION_EXTRA)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end