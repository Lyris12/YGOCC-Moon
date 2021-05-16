--IF, Awakened Flame
function c68709351.initial_effect(c)
	--link summon
    aux.AddLinkProcedure(c,c68709351.lfilter,1,1)
    c:EnableReviveLimit()
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68709351,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,68709351)
	e1:SetCondition(c68709351.mvcon)
	e1:SetTarget(c68709351.mvtg)
	e1:SetOperation(c68709351.mvop)
	c:RegisterEffect(e1)
	--special summon from extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68709351,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,69709351)
	e2:SetCost(c68709351.spcost1)
	e2:SetTarget(c68709351.sptg1)
	e2:SetOperation(c68709351.spop1)
	c:RegisterEffect(e2)
end
function c68709351.lfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf08)
end
function c68709351.mvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c68709351.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
end
function c68709351.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsControler(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,fd)
	local seq=math.log(fd,2)
	local pseq=c:GetSequence()
	Duel.MoveSequence(c,seq)
end
function c68709351.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c68709351.cfilter1(c)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER)and c:IsAbleToRemoveAsCost()
end
function c68709351.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
function c68709351.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0xf09)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c68709351.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(c68709351.cfilter1,tp,LOCATION_GRAVE,0,nil)
	local tg=Duel.GetMatchingGroup(c68709351.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c68709351.fselect,1,maxlink,tg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=cg:SelectSubGroup(tp,c68709351.fselect,false,1,math.min(#cg,3),tg)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c68709351.spfilter1(c,e,tp,lk)
	return c68709351.spfilter(c,e,tp) and c:IsLink(lk)
end
function c68709351.spop1(e,tp,eg,ep,ev,re,r,rp)
	local lk=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c68709351.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c68709351.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end