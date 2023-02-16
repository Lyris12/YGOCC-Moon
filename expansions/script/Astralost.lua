--Astralost Commons

Astralost=Astralost or {}

Astralost.Code = 0x250
function Astralost.Is(c) return c:IsSetCard(Astralost.Code) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD)) end
function Astralost.GetHealCount(p)
	if p==PLAYER_ALL then return Astralost.HealCounter[0]+Astralost.HealCounter[1]
	else return Astralost.HealCounter[p] end
end
function Astralost.EachRecover(val)
	Duel.Recover(0,val,REASON_EFFECT)
	Duel.Recover(1,val,REASON_EFFECT)
end

function Astralost.EnableHealCounter()
	if not Astralost.HealCounter then
		Astralost.HealCounter={}
		Astralost.HealCounter[0]=0
		Astralost.HealCounter[1]=0
		local e1=Effect.GlobalEffect()
		e1:SetCode(EVENT_RECOVER)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Astralost.HealCounter[ep]=Astralost.HealCounter[ep]+ev end)
		Duel.RegisterEffect(e1,0)
		local e2=Effect.GlobalEffect()
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		--e2:SetCondition(function() return not ((Astralost.HealCounter[0]+Astralost.HealCounter[1])==0) end)
		e2:SetOperation(function() Astralost.HealCounter[0]=0 Astralost.HealCounter[1]=0 end)
		Duel.RegisterEffect(e2,0)
	end
end
function Astralost.CreateHealTrigger(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RECOVER)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
	return e1
end

function Astralost.AddManaEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28940040,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(Astralost.ManaCost)
	e1:SetTarget(Astralost.HandSSTarget)
	e1:SetOperation(Astralost.HandSSOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(28940040,1))
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,PLAYER_ALL,200) end)
	e2:SetOperation(function() Astralost.EachRecover(200) end)
	c:RegisterEffect(e2)
end
function Astralost.ManaCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 then
		c:RegisterFlagEffect(28940040,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
		e1:SetCondition(Astralost.ManaReturnCondition)
		e1:SetOperation(function(e) Duel.SendtoGrave(e:GetLabelObject(),REASON_RETURN) end)
		Duel.RegisterEffect(e1,tp)
	end
end
function Astralost.ManaReturnCondition(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(28940040)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function Astralost.HandSSFilter(c,e,tp) return Astralost.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function Astralost.HandSSTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Astralost.HandSSFilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function Astralost.HandSSOperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,Astralost.HandSSFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end
