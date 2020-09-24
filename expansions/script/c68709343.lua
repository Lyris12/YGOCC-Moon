--Plutia
--Coded by Concordia
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(cid.spcost)
	c:RegisterEffect(e1)
	--foolish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,68709343)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	--token
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,68709443)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(cid.tkcon)
	e3:SetTarget(cid.tktg)
	e3:SetOperation(cid.tkop)
	c:RegisterEffect(e3)
end
function cid.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER)
end
function cid.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_NORMAL+SUMMON_TYPE_SPECIAL)~=SUMMON_TYPE_NORMAL+SUMMON_TYPE_SPECIAL then return true end
	return Duel.IsExistingMatchingCard(cid.sfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.filter(c)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and not c:IsCode(68709343) and c:IsAbleToGrave()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp
end
function cid.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,68709350,0xea,0x4011,500,500,3,RACE_FIEND,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function cid.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,68709350,0xea,0x4011,500,500,3,RACE_FIEND,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,68709350)
	Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP)
end