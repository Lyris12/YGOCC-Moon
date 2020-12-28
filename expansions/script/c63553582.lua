--Marshall Arts
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:GLString(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:GLString(1)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--sp effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.effcon)
	e2:SetTarget(cid.tdtg)
	e2:SetOperation(cid.tdop)
	e2:SetLabel(TYPE_PENDULUM)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetDescription(aux.Stringid(id,3))
	e2x:SetCountLimit(1,id+200)
	e2x:SetTarget(cid.tdtg2)
	e2x:SetOperation(cid.tdop2)
	e2x:SetLabel(100)
	c:RegisterEffect(e2x)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCountLimit(1,id+300)
	e3:SetTarget(cid.drytg)
	e3:SetOperation(cid.dryop)
	e3:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,id+400)
	e4:SetTarget(cid.drtg)
	e4:SetOperation(cid.drawop)
	e4:SetLabel(TYPE_SYNCHRO)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetDescription(aux.Stringid(id,6))
	e5:SetCountLimit(1,id+500)
	e5:SetTarget(cid.xyztg)
	e5:SetOperation(cid.xyzop)
	e5:SetLabel(TYPE_XYZ)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetDescription(aux.Stringid(id,7))
	e6:SetCountLimit(1,id+600)
	e6:SetTarget(cid.linktg)
	e6:SetOperation(cid.linkop)
	e6:SetLabel(TYPE_LINK)
	c:RegisterEffect(e6)
end
--SPECIAL SUMMON
function cid.dryfilter(c,e,tp)
	if not c:IsSetCard(0x7a4) then return false end
	local check=true
	if c:IsLocation(LOCATION_HAND) then
		check=c:IsAbleToRemove()
	elseif c:IsOnField() then
		check=c:IsFaceup() and c:IsAbleToRemove()
	end
	return check and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function cid.filter(c,e,tp,mc)
	local sumtype,smat=0,nil
	if c:IsType(TYPE_FUSION) then sumtype=SUMMON_TYPE_FUSION smat=EFFECT_MUST_BE_FMATERIAL
	elseif c:IsType(TYPE_SYNCHRO) then sumtype=SUMMON_TYPE_SYNCHRO smat=EFFECT_MUST_BE_SMATERIAL
	elseif c:IsType(TYPE_XYZ) then sumtype=SUMMON_TYPE_XYZ smat=EFFECT_MUST_BE_XMATERIAL
	elseif c:IsType(TYPE_LINK) then sumtype=SUMMON_TYPE_LINK smat=EFFECT_MUST_BE_LMATERIAL
	end
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsCanBeSpecialSummoned(e,sumtype,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and (not smat or aux.MustMaterialCheck(nil,tp,smat))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),e,tp)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
		if tc then
			local sumtype=0
			if tc:IsType(TYPE_FUSION) then sumtype=SUMMON_TYPE_FUSION
			elseif tc:IsType(TYPE_SYNCHRO) then sumtype=SUMMON_TYPE_SYNCHRO
			elseif tc:IsType(TYPE_XYZ) then sumtype=SUMMON_TYPE_XYZ
			elseif tc:IsType(TYPE_LINK) then sumtype=SUMMON_TYPE_LINK
			end
			--Debug.Message(tostring(sumtype))
			Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

--SP EFFECTS
function cid.mfilter(c,tp,typ)
	if typ==100 then typ=TYPE_PANDEMONIUM end
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsControler(tp) and c:IsType(typ)
end
function cid.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0 and eg:IsExists(cid.mfilter,1,nil,tp,e:GetLabel())
end
function cid.tdfilter(c,typ)
	return c:IsSetCard(0x7a4) and c:IsType(typ) and c:IsAbleToHand()
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_PENDULUM) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.tdfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,TYPE_SPELL+TYPE_PENDULUM)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function cid.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,TYPE_TRAP+TYPE_PANDEMONIUM) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cid.tdop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.tdfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,TYPE_TRAP+TYPE_PANDEMONIUM)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
------
function cid.drytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.dryop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
------
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.drawop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-------
function cid.xyzfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function cid.xyzfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function cid.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.xyzfilter,tp,0,LOCATION_HAND+LOCATION_MZONE,1,nil,e) and eg:IsExists(Card.IsType,1,nil,TYPE_XYZ) end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
end
function cid.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local xg=eg:Filter(cid.xyzfilter2,nil)
	local tc
	if #xg==1 then
		tc=xg:GetFirst()
	else
		tc=xg:Select(tp,1,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(1-tp,cid.xyzfilter,tp,0,LOCATION_HAND+LOCATION_MZONE,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Overlay(tc,g)
	end
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
--------
function cid.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7a4) or c:IsLinkState()
end
function cid.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
	e:GetHandler():RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END,0,1)
end
function cid.linkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7a4))
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if e:GetHandler():GetFlagEffect(id+100)>1 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end