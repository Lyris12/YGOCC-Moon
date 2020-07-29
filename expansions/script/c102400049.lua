--created & coded by Lyris, art from Cardfight!! Vanguard's "Mistress Hurricane"
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xc74),5,3,cid.ovfilter,aux.Stringid(id,0))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(function(e,c) return Duel.GetOverlayGroup(e:GetHandlerPlayer(),1,0):FilterCount(Card.IsSetCard,nil,0xc74)*100 end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(cid.atkcon)
	e3:SetCost(cid.atkcost)
	e3:SetOperation(cid.atkop)
	c:RegisterEffect(e3)
end
function cid.ovfilter(c)
	return c:IsFaceup() and c:IsRank(4) and c:IsSetCard(0x2c74)
end
function cid.filter(c,e,tp)
	return c:IsSetCard(0x1c74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():GetOverlayGroup():IsExists(cid.filter,1,nil,e,tp) end
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(c:GetOverlayGroup():FilterSelect(tp,cid.filter,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac,bc=Duel.GetBattleMonster(tp)
	return (ac==c or bc==c) and bc and bc:IsPosition(POS_ATTACK) and bc:IsDefenseAbove(0)
end
function cid.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if d==c then d,a=a,d end
	if a:IsRelateToBattle() and d and d:IsRelateToBattle() then
		local ed=Effect.CreateEffect(c)
		ed:SetType(EFFECT_TYPE_SINGLE)
		ed:SetCode(EFFECT_SET_BATTLE_ATTACK)
		ed:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ed:SetValue(d:GetDefense())
		d:RegisterEffect(ed,true)
	end
end
