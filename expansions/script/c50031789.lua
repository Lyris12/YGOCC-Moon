--Leaf-Chan
function c50031789.initial_effect(c)
	  c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50031789,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c50031789.spcon)
	e1:SetTarget(c50031789.sptg)
	e1:SetOperation(c50031789.spop)
	c:RegisterEffect(e1)
  local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
  local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
  --unXyzable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
  --nO to link material
	local e666=Effect.CreateEffect(c)
	e666:SetType(EFFECT_TYPE_SINGLE)
	e666:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e666:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e666:SetValue(1)
	c:RegisterEffect(e666)
   --lv up
	local e786=Effect.CreateEffect(c)
	e786:SetDescription(aux.Stringid(50031789,1))
	e786:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e786:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e786:SetCode(EVENT_SPSUMMON_SUCCESS)
	e786:SetTarget(c50031789.target)
	e786:SetOperation(c50031789.operation)
	c:RegisterEffect(e786)
end
function c50031789.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsRace(RACE_PLANT)
end
function c50031789.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c50031789.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
function c50031789.filter(c,e)
	return  c:IsFaceup() and c:GetLevel()>e:GetHandler():GetLevel()
end
function c50031789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   if chkc then return chkc:IsOnField() and c50031789.filter(chkc,e) end
if chk==0 then return Duel.IsExistingTarget(c50031789.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
Duel.SelectTarget(tp,c50031789.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
end
function c50031789.operation(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
local tb={1,2}
if tc:IsFaceup() and tc:IsRelateToEffect(e) then
local lv=Duel.AnnounceNumber(tp,table.unpack(tb))
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_LEVEL)
e1:SetValue(-lv)
e1:SetReset(RESET_EVENT+0x1fe0000)
tc:RegisterEffect(e1)
end
end
