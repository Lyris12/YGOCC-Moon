--Mysterious Samsara Dragon
function c53313916.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P-You can Tribute 1 monster you control; Special Summon 1 Level 5-7 "Mysterious" monster from your hand, Deck, or face-up from your Extra Deck, and if you do, destroy this card. (HOPT1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetCondition(aux.PandActCheck)
	e1:SetCost(c53313916.pspcost)
	e1:SetTarget(c53313916.psptg)
	e1:SetOperation(c53313916.pspop)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1)
	--P-You cannot Pandemonium Summon monsters, except LIGHT Dragon monsters. This effect cannot be negated.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(c53313916.splimit)
	c:RegisterEffect(e0)
	--M-To Tribute Summon this card face-up, you must Tribute 1 Pandemonium Monster you control and 1 card in your Pandemonium Zone. (HOPT2)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e2:SetCondition(c53313916.ttcon)
	e2:SetOperation(c53313916.ttop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	--M-When exactly 1 face-up "Mysterious" or LIGHT Dragon monster you control is destroyed by battle or an opponent's card effect, and no other cards: You can Special Summon this card from your hand or face-up from your Extra Deck, and if you do, this card gains that monster's effects (if any), until the end of the turn. (HOPT2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e3:SetCountLimit(1,53313916)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(c53313916.spcon)
	e3:SetTarget(c53313916.sptg)
	e3:SetOperation(c53313916.spop)
	c:RegisterEffect(e3)
	--M-Once per turn: You can have this card gain the ATK, DEF and effects (if any) of 1 face-up monster on the field, GY, Extra Deck, or that is banished until the end of this turn, except "Mysterious Samsara Dragon" or your non-"Mysterious" monster. (HOPT2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,53313916)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetTarget(c53313916.target)
	e4:SetOperation(c53313916.copy)
	c:RegisterEffect(e4)
	--M-Cannot be targeted by your opponent's card effects.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
function c53313916.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) then return false end
	return aux.PandActCheck(e) and bit.band(sumtype,SUMMON_TYPE_SPECIAL+726)==SUMMON_TYPE_SPECIAL+726
end
function c53313916.pspcfilter(c,e,tp)
	local loc=0
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:GetSequence()<5 then ft=ft+1 end
	if ft>0 then loc=loc+LOCATION_HAND+LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp,tp,c)>0 then loc=loc+LOCATION_EXTRA end
	return loc~=0 and Duel.IsExistingMatchingCard(c53313916.pspfilter,tp,loc,0,1,nil,e,tp)
end
function c53313916.pspfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsLevelBelow(7) and c:IsSetCard(0xcf6)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c53313916.pspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c53313916.pspcfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,c53313916.pspcfilter,1,1,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function c53313916.psptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.GetFlagEffect(tp,53313916)==0 end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	Duel.RegisterFlagEffect(tp,53313916,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c53313916.pspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c53313916.pspfilter,tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
function c53313916.ttfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)
 end
function c53313916.ttcon(e,c,minc)
	if c==nil then return true end
	local pc=Duel.GetFirstMatchingCard(c53313916.ttfilter,tp,LOCATION_SZONE,0,nil)
	return minc<=3 and pc and Duel.GetTributeGroup(c):IsExists(Card.IsType,2,nil,TYPE_PANDEMONIUM)
end
function c53313916.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TRIBUTE)
	local g=Duel.GetTributeGroup(c):FilterSelect(tp,Card.IsType,2,2,nil,TYPE_PANDEMONIUM)
	g=g+Duel.GetFirstMatchingCard(c53313916.ttfilter,tp,LOCATION_SZONE,0,nil)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
function c53313916.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	e:SetLabelObject(c)
	return eg:GetCount()==1 and (c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsRace(RACE_DRAGON) or c:IsSetCard(0xcf6))
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()~=tp)
end
function c53313916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		or Duel.GetLocationCountFromEx(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c53313916.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		c:CopyEffect(e:GetLabelObject():GetCode(),RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	end
end
function c53313916.copytg(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and (c:IsSetCard(0xcf6) or c:IsControler(1-tp)) and not c:IsCode(53313916)
end
function c53313916.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313916.copytg,tp,0x74,0x74,1,nil,tp) end
end
function c53313916.copy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c53313916.copytg,tp,0x74,0x74,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.HintSelection(g)
	c:CopyEffect(tc:GetCode(),RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(tc:GetDefense())
	c:RegisterEffect(e2)
end
