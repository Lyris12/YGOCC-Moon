local m=8886673
local cm=_G["c"..m]

--Tainted Minds
function cm.initial_effect(c)
	--  runcost
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0a:SetCode(EVENT_PREDRAW)
	e0a:SetRange(LOCATION_EXTRA)
	e0a:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
	e0a:SetOperation(cm.start)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0b:SetCode(EVENT_PREDRAW)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetCountLimit(1)
	e0b:SetOperation(cm.start2)
	c:RegisterEffect(e0b)

--passives
	
	--lp cost replace
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_LPCOST_REPLACE)
	e1:SetCondition(cm.lrcon)
	e1:SetOperation(cm.lrop)
	c:RegisterEffect(e1)
	-- extra normal summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetCondition(cm.escon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PSYCHO))
	c:RegisterEffect(e2)

--  Activated Effect

	-- Psychic Bonds
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetTarget(cm.sptg)
	e3:SetOperation(cm.spop)
	c:RegisterEffect(e3)

--  Turn Modifier

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetTarget(cm.mregtg)
	e4:SetOperation(cm.regop)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_END)
--	e5:SetCondition(cm.reccon)
	e5:SetTarget(cm.rectg)
	e5:SetOperation(cm.recop)
	c:RegisterEffect(e5)

	if not cm.global_check then
		cm.global_check=true
		cm[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(cm.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(cm.clear)
		Duel.RegisterEffect(ge2,0)
	end
end

function cm.mregtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local echos=Duel.GetFlagEffectLabel(tp,88866600)
	local cost=50
	local new= echos-cost 
	Duel.SetFlagEffectLabel(tp,88866600,new)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=40
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Debug.Message(2)
end

function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	cm[0]=cm[0]+eg:FilterCount(Card.IsRace,nil,RACE_PSYCHO)
	Debug.Message(cm[0])
end

function cm.clear(e,tp,eg,ep,ev,re,r,rp)
	cm[0]=0
end

function cm.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(m)>0
end

function cm.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return cm[0]~=0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(cm[0]*1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,cm[0]*1000)
end

function cm.recop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	Duel.Recover(p,cm[0]*1000,REASON_EFFECT)
end

function cm.escon(e,tp,eg,ep,ev,re,r,rp)
	local tp = e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=60
	return corruption>=threshold
end

function cm.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	local lp=Duel.GetLP(ep)
	if lp<ev then return false end
	if not re or not re:IsHasType(0x7e0) then return false end
	local rc=re:GetHandler()
--  cost
	local tp = e:GetHandlerPlayer()
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local threshold=30
	return corruption>=threshold and rc:IsLocation(LOCATION_MZONE) and rc:IsRace(RACE_PSYCHO) 
end

function cm.lrop(e,tp,eg,ep,ev,re,r,rp)
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=10
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
	Duel.SetChainLimit(aux.FALSE)   
end


function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	Duel.Remove(c,tp,REASON_EFFECT)
	Duel.SendtoExtraP(c,tp,REASON_EFFECT)
end

function cm.start2(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,88866601) < 1) then
		Duel.RegisterFlagEffect(tp,88866601,RESET_DISABLE,0,1)
	end
	local corruption=Duel.GetFlagEffectLabel(tp,88866601)
	local inc=5
	local newc= corruption+inc
	Duel.SetFlagEffectLabel(tp,88866601,newc)
end

function cm.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and cm.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(cm.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) then 
		local inc=tc:GetLevel()*8
		local newc= corruption+inc
		Duel.SetFlagEffectLabel(tp,88866601,newc)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

