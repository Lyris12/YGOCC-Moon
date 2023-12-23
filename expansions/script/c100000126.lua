--MMS - Galaxy-Eyes Liberator Dragon
--MMS - Drago Liberatore Occhi Galattici
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute 2 other "MMS -", "Photon", and/or "Galaxy" monsters, from your hand and/or field; Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(nil,s.hspcost,s.hsptg,s.hspop)
	c:RegisterEffect(e1)
	--At the start of the Damage Step, if this card battles an opponent's monster: You can banish that monster, until the end of the Battle Phase.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
	--A Fusion Monster whose original name is "MMS - Jacklyn Alltrades", and that was Fusion Summoned using this card as material, gains the following effects.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
--E1
function s.hspfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_MMS,ARCHE_PHOTON,ARCHE_GALAXY) and (c:IsControler(tp) or c:IsFaceup())
end
function s.gcheck(g,tp)
	return aux.mzctcheck(g,tp) and Duel.CheckReleaseGroupEx(REASON_COST,tp,aux.IsInGroup,#g,nil,g)
end
function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetReleaseGroup(tp,true):Filter(s.hspfilter,e:GetHandler(),tp)
	if chk==0 then return #g>1 and g:CheckSubGroup(s.gcheck,2,2,tp) end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	if #sg>0 then
		Duel.Release(sg,REASON_COST)
	end
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemoveTemp(tp) end
	Duel.SetCardOperationInfo(tc,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		Duel.BanishUntil(tc,e,tp,nil,PHASE_BATTLE,id,1,false,c,REASON_EFFECT)
	end
end

--E3
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r&REASON_FUSION~=0 and rc and rc:IsMonster(TYPE_FUSION) and rc:IsOriginalCodeRule(CARD_MMS_JACKLYN_ALLTRADES)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--This card can attack all monsters your opponent controls, once each.
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	--At the start of the Damage Step, if this card battles an opponent's monster: You can banish that monster, until the end of the Battle Phase.
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.rmtg,s.rmop)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end