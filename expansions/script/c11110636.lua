--Oscurion Type-10 ‹Endless Hunger›
--Oscurione Tipo-10 ‹Fame Infinita›
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,25)
	aux.AddCodeList(c,CARD_LIMIERRE)
	--[[ [-10]: (Quick Effect): You can target 1 "Limiérre, the All-Consuming" you control; destroy all monsters on the field,
	except that target, and if you do, that target gains 500 ATK/DEF for each card destroyed by this effect.
	Monsters destroyed by this effect are treated as being destroyed by the effect of "Limiérre, the All-Consuming".]]
	c:DriveEffect(-10,0,CATEGORY_DESTROY|CATEGORIES_ATKDEF,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.destg,
		s.desop
	)
	--[[[-5]: (Quick Effect): You can discard 1 other "Oscurion" card, or 1 other card that mentions "Limiérre, the All-Consuming"; destroy 1 Spell/Trap on the field.]]
	local d2=c:DriveEffect(-5,1,CATEGORY_DESTROY,EFFECT_TYPE_QUICK_O,nil,nil,
		nil,
		aux.DiscardCost(s.dcfilter,1,1,true),
		s.destg2,
		s.desop2
	)
	aux.RegisterOscurionDiscardCostEffectFlag(c,d2)
	--[[[OD]: Special Summon 1 "Oscurion" Time Leap monster from your Extra Deck.]]
	c:OverDriveEffect(2,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.tltg,
		s.tlop
	)

	--[[If you Ritual Summon "Limiérre, the All-Consuming" (except during the Damage Step): You can Special Summon this from your GY.]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:HOPT()
	e1:SetLabelObject(GYChk)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Drive Summoned, or Special Summoned by its own effect: You can send 1 "Oscurion" card, or 1 card that mentions "Limiérre, the All-Consuming", from your Deck to your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	aux.RegisterOscurionDriveSummonEffectFlag(c,e2)
	--[[If this card is destroyed by the effect of "Limiérre, the All-Consuming": You can add this card to your hand, and if you do, you can Engage it.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(5)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:HOPT()
	e3:SetCondition(s.dscon)
	e3:SetTarget(s.dstg)
	e3:SetOperation(s.dsop)
	c:RegisterEffect(e3)
	if not s.TriggeringSetcodeCheck then
		s.TriggeringSetcodeCheck=true
		s.TriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid,code1,code2=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	local rc=re:GetHandler()
	if code1==CARD_LIMIERRE or code2==CARD_LIMIERRE then
		s.TriggeringSetcode[cid]=true
		return
	end
	s.TriggeringSetcode[cid]=false
end

--FILTERS D1
function s.limfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_LIMIERRE) 
end
--D1
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.limfilter(chkc) end
	local mzg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then
		return Duel.IsExists(true,s.limfilter,tp,LOCATION_MZONE,0,1,nil) and #mzg>1
	end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.limfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	mzg:RemoveCard(tc)
	Duel.SetCardOperationInfo(mzg,CATEGORY_DESTROY)
	local p,loc,val = tc:GetControler(),tc:GetLocation(),#mzg*500
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,p,loc,val)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,tc,1,p,loc,val)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local tgchk = (tc and tc:IsRelateToChain() and s.limfilter(tc))
	local exc = tgchk and tc or nil
	local mgz=Duel.Group(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	if #mgz>0 then
		for rc in aux.Next(mgz) do
			rc:RegisterFlagEffect(CARD_LIMIERRE,RESET_CHAIN,0,1)
		end
		local ct=Duel.Destroy(mgz,REASON_EFFECT)
		for rc in aux.Next(mgz) do
			rc:ResetFlagEffect(CARD_LIMIERRE)
		end
		tgchk = (tc and tc:IsRelateToChain() and s.limfilter(tc))
		if ct>0 and tgchk and tc:IsFaceup() then
			local val=ct*500
			tc:UpdateATKDEF(val,val,true,e:GetHandler())
		end
	end
end

--FILTERS D2
function s.dcfilter(c)
	return c:IsSetCard(ARCHE_OSCURION) or aux.IsCodeListed(c,CARD_LIMIERRE)
end
--D2
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsSpellTrapOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g==0 then return end
	Duel.HintMessage(tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--FILTERS D3
function s.tlfilter(c,e,tp)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_OSCURION) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--D3
function s.tltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tlop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.tlfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:Desc(7)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_ADD_CODE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(CARD_LIMIERRE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e2)
	end
end

--FILTERS E1
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsCode(CARD_LIMIERRE) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsSummonPlayer(tp) and (se==nil or c:GetReasonEffect()~=se)
end
--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,1,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end

--FILTERS E2
function s.tgfilter(c)
	return (c:IsSetCard(ARCHE_OSCURION) or aux.IsCodeListed(c,CARD_LIMIERRE)) and c:IsAbleToGrave()
end
--E2
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.DriveSummonedCond(e) or e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--E3
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsReason(REASON_EFFECT) then return false end
	if c:HasFlagEffect(CARD_LIMIERRE) then return true end
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return s.TriggeringSetcode[cid]==true
		
	else
		return rc:IsCode(CARD_LIMIERRE)
	end
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SearchAndEngage(c,e,tp)
	end
end