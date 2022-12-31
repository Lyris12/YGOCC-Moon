--Crime Punisher
function c500310045.initial_effect(c)
		 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(500310045)
 aux.AddEvoluteProc(c,nil,7,c500310045.filter1,2,2)  

--spsummon proc
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(500310045,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,500310045)
	e0:SetCondition(c500310045.hspcon)
	e0:SetOperation(c500310045.hspop)
	e0:SetValue(SUMMON_TYPE_SPECIAL+388)
	c:RegisterEffect(e0)
	 --disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c500310045.con)
	e3:SetTarget(c500310045.distg)
	--e3:SetValue(aux.ExceptThisCard(e))
	c:RegisterEffect(e3)
		--tohand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(500310045,1))
	--e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c500310045.thcon)
	e4:SetOperation(c500310045.thop)
	c:RegisterEffect(e4)
end
function c500310045.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_CYBERSE)
end

function c500310045.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsLinkAbove(4) and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function c500310045.hspcon(e,c)
  if c==nil then return true end
	if chk==0 then return Duel.GetFlagEffect(tp,500310045)==0 end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c500310045.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c500310045.hspop(e,tp,eg,ep,ev,re,r,rp)
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_MATERIAL)
	local g=Duel.SelectMatchingCard(tp,c500310045.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
   Duel.SendtoGrave(g,REASON_MATERIAL+0x10000000)
	Duel.RegisterFlagEffect(tp,500310045,RESET_PHASE+PHASE_END,0,1)
end
function c500310045.con(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetEC()==7
end
function c500310045.distg(e,c)
	return c:GetSummonLocation()==LOCATION_EXTRA and not c:IsLinkState() and not c:IsImmuneToEffect(e) and not c:IsCode(500310045)
end
function c500310045.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp
end
function c500310045.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable(ignore)
end

function c500310045.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,c500310045.thfilter,tp,LOCATION_DECK,0,1,1,nil,false)
		 local tc=g:GetFirst()
		if g:GetCount()>0 then
				 Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
	end
end
